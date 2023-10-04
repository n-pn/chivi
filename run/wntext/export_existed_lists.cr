DIR = "/2tb/var.chivi/_prev/ztext"
OUT = "/www/chivi/txt/saved"

def export_book(txt_path : String)
  files = Dir.children(txt_path).map! { |x| File.basename(x).split('.').first }
  out_path = txt_path.sub(DIR, OUT).sub(/\/$/, ".txt")
  puts "#{txt_path} => #{out_path}"
  File.write(out_path, files.join(' '))
end

def export_seed(sname : String)
  Dir.mkdir_p("#{OUT}/#{sname}")
  Dir.glob("#{DIR}/#{sname}/*/").each do |txt_path|
    export_book(txt_path)
  end
end

# export_seed("!bxwxorg.com")
# export_seed("!jx.la")
# export_seed("!shubaow.net")
# export_seed("!nofff.com")
# export_seed("!xbiquge.bz")
# export_seed("!duokan8.com")
export_seed("!5200.tv")
