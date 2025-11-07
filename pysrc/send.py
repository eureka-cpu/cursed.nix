#!/usr/bin/env python3

import os, sys, socket

if len(sys.argv) < 2:
    print("Usage: python send.py <chunk-file>")
    sys.exit(1)

chunk_file = sys.argv[1]

HOST = os.getenv("HOST", "127.0.0.1")
PORT = int(os.getenv("RECV_PORT", "6000"))

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect((HOST, PORT))

with open(chunk_file, "rb") as f:
    chunk = f.read()

s.sendall(b"python:" + chunk)
s.close()
