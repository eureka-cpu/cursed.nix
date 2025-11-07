#!/usr/bin/env lua

local socket = require("socket")

if #arg < 1 then
    print("Usage: lua send.lua <chunk-file>")
    os.exit(1)
end

local chunk_file = arg[1]

local host = os.getenv("HOST") or "127.0.0.1"
local port = tonumber(os.getenv("RECV_PORT") or "6000")

local client = assert(socket.tcp())
assert(client:connect(host, port))

local f = assert(io.open(chunk_file, "rb"))
local chunk = f:read("*all")
f:close()
local msg = "lua:" .. chunk

client:send(msg)
client:close()
