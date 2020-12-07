require "../../src/engine/library"

module Chivi
  puts Library.hanviet.size
  puts Library.hanviet.find("坚")

  Library.hanviet.each do |term|
    puts term
  end
end
