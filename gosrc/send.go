package main

import (
	"fmt"
	"net"
	"os"
	"io/ioutil"
)

func main() {
	if len(os.Args) < 2 {
		fmt.Println("Usage: go run send.go <chunk-file>")
		os.Exit(1)
	}

	chunkFile := os.Args[1]

	host := getenv("HOST", "127.0.0.1")
	port := getenv("RECV_PORT", "6000")

	conn, err := net.Dial("tcp", fmt.Sprintf("%s:%s", host, port))
	if err != nil {
		fmt.Println("Err:", err)
		return
	}
	defer conn.Close()

	chunk, err := ioutil.ReadFile(chunkFile)
	if err != nil {
		fmt.Println("Failed to read chunk:", err)
		return
	}
	conn.Write([]byte("go:"))
	conn.Write(chunk)
}

func getenv(k, def string) string {
	if v := os.Getenv(k); v != "" {
		return v
	}
	return def
}
