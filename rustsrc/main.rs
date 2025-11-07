use axum::{Router, response::IntoResponse, routing::get};
use std::{
    collections::HashMap,
    env,
    sync::{Arc, Mutex},
};
use tokio::{io::AsyncReadExt, net::TcpListener};

#[tokio::main]
async fn main() {
    let subscriber = tracing_subscriber::fmt()
        .with_writer(std::io::stdout)
        .pretty()
        .finish();
    tracing::subscriber::set_global_default(subscriber).expect("Could not set up global logger");

    let host = env::var("HOST").unwrap_or_else(|_| "127.0.0.1".to_string());
    let recv_port = env::var("RECV_PORT").unwrap_or_else(|_| "6000".to_string());
    let serve_port = env::var("SERVE_PORT").unwrap_or_else(|_| "4000".to_string());

    let buffer = Arc::new(Mutex::new(HashMap::<String, Vec<u8>>::new()));
    let final_img = Arc::new(Mutex::new(Vec::<u8>::new()));

    {
        let buffer = Arc::clone(&buffer);
        let final_img = Arc::clone(&final_img);
        tokio::spawn({
            let host = host.clone();
            async move {
                let addr = format!("{}:{}", host, recv_port);
                let listener = TcpListener::bind(&addr).await.unwrap();
                tracing::error!("Listening for chunks on {}", addr);

                while let Ok((mut stream, peer)) = listener.accept().await {
                    tracing::error!("Connection from {}", peer);
                    let buffer = Arc::clone(&buffer);
                    let final_img = Arc::clone(&final_img);
                    tokio::spawn(async move {
                        tracing::error!("spawned task to handle chunk");
                        let mut bytes = Vec::new();
                        let _ = stream.read_to_end(&mut bytes).await;
                        tracing::error!("finished reading chunk");

                        if let Some(pos) = bytes.iter().position(|&b| b == b':') {
                            let lang = String::from_utf8_lossy(&bytes[..pos]).trim().to_string();
                            let chunk = &bytes[pos + 1..];
                            let mut buf = buffer.lock().unwrap();
                            tracing::error!("Got chunk from {}", lang);
                            buf.insert(lang, chunk.to_vec());
                        }

                        let mut buf = buffer.lock().unwrap();
                        if buf.len() == 3 {
                            let mut full = Vec::new();
                            for lang in ["go", "lua", "python"] {
                                if let Some(c) = buf.remove(lang) {
                                    full.extend_from_slice(&c);
                                }
                            }
                            let mut img = final_img.lock().unwrap();
                            *img = full;
                            tracing::info!("Breaking the curse!");
                        }
                    });
                }
            }
        });
    }

    let app = {
        let final_img = Arc::clone(&final_img);
        Router::new().route(
            "/image",
            get(move || {
                let img = final_img.lock().unwrap().clone();
                async move {
                    if img.is_empty() {
                        (axum::http::StatusCode::NOT_FOUND, "CURSED").into_response()
                    } else {
                        ([(axum::http::header::CONTENT_TYPE, "image/jpeg")], img).into_response()
                    }
                }
            }),
        )
    };

    let listener = TcpListener::bind(format!("{host}:{serve_port}"))
        .await
        .expect("failed to bind to address");
    tracing::error!("Serving at http://{}/image", listener.local_addr().unwrap());
    axum::serve(listener, app.into_make_service())
        .await
        .unwrap()
}
