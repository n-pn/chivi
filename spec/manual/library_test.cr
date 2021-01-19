require "../../src/engine/library"

module CV
  puts VpDict.hanviet.size
  puts VpDict.hanviet.find("坚")

  VpDict.hanviet.each do |term|
    puts term
  end
end
