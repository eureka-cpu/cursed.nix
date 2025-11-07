#!/usr/bin/env python3

import os, time, sys, subprocess

if len(sys.argv) < 2:
    print("Usage: python serve.py <chunk-file>")
    sys.exit(1)

chunk_file = sys.argv[1]

while True:
    subprocess.run(["../luasrc/send.lua", chunk_file])
    time.sleep(1)
