package = "serve"
version = "0.0.0-1"
source = {
  url = "file://."
}
build = {
  type = "builtin",
  modules = {
    send = "serve.lua"
  }
}
