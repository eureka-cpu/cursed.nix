package main

import (
	"os"
	"os/exec"
	"time"
	"fmt"
)

func main() {
	if len(os.Args) < 2 {
		fmt.Println("Usage: go run serve.go <chunk-file>")
		os.Exit(1)
	}

	chunkFile := os.Args[1]

	for {
		cmd := exec.Command("../pysrc/send.py", chunkFile)
		if err := cmd.Run(); err != nil {
		    fmt.Println("Error running command:", err)
		}
		time.Sleep(1 * time.Second)
	}
}
