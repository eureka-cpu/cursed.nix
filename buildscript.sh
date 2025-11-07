#!/usr/bin/env bash
cargo build

go build -o gosrc/serve gosrc/serve.go

go build -o gosrc/send gosrc/send.go
