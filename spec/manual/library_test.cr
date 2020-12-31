require "../../src/engine/library"

module CV
  puts Library.hanviet.size
  puts Library.hanviet.find("坚")

  Library.hanviet.each do |term|
    puts term
  end
end
