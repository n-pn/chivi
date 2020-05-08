require "json"
require "colorize"
require "file_utils"

require "../src/engine"
require "../src/models/zh_list"
require "../src/models/vp_list"

def translate(input : String)
  return input if input.empty?
  Engine.translate(input, :title, nil, "local")
end
