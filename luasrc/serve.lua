#!/usr/bin/env lua

local socket = require("socket")

if #arg < 1 then
    print("Usage: lua serve.lua <chunk-file>")
    os.exit(1)
end

local chunk_file = arg[1]

while true do
  os.execute("../gosrc/send " .. chunk_file)
  socket.sleep(1)
end
