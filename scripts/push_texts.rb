INP_DIR = File.join("data", "zh_texts")
OUT_DIR= "nipin@ssh.chivi.xyz:web/chivi/data/zh_texts/"

def sync_site(site)
  list = Dir.glob(File.join(INP_DIR, "#{site}.*"))
  puts "- #{site}: #{list.size} entries"
  list.each do |path|
    puts path

    `rsync -azi --chmod=Dg+s,ug+w,Fo-w,+X "#{path}" "#{OUT_DIR}"`
  end

end

sync_site("hetushu")
sync_site("zhwenpg")
sync_site("paoshu8")
