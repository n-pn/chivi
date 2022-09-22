require "lexbor"
require "colorize"
INP = "var/.cached/archive"

dirs = Dir.children(INP).sort_by(&.to_i64.-)

dirs.each do |dir|
  inp_dir = File.join(INP, dir)

  book_infos = Dir.glob("#{inp_dir}/booklist/*/index.html")
  next if book_infos.empty?

  book_infos.each do |file|
    extract_preload_json(file, dir)
  end
end

def extract_preload_json(file, dir = "")
  id = File.basename(File.dirname(file))

  data = File.read(file)
  return unless data.includes?("__INITIAL_STATE__")
  puts "#{id}: #{file}".colorize.cyan

  page = Lexbor::Parser.new(data)
  page.css("script").each do |node|
    next if node.attributes["src"]?
    text = node.inner_text
    next unless text.starts_with?("window")
    return cleanup(text, id, dir)
  end
end

def cleanup(text : String, id : String, dir : String) : Nil
  out_file = "var/ysinfos/archive/booklists/#{id}-#{dir}.json"
  return if File.exists?(out_file)

  text = text.sub("window.__INITIAL_STATE__", "const data")
  text = text.sub("(function(){var s;(s=document.currentScript||document.scripts[document.scripts.length-1]).parentNode.removeChild(s);}());", "")

  text += "\nconst fs = require('fs')"
  text += "\nfs.writeFileSync('#{out_file}', JSON.stringify(data, null, 2))"

  js_file = "tmp/harvest/#{id}.js"
  File.write(js_file, text)
  `node #{js_file}`
  File.delete(js_file)
end
