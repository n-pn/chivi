require "json"

INP = "_db/prime/chdata/texts"
OUT = "nipin@ssh.nipin.xyz:web/chivi/#{INP}"

def upload_texts(seed)
  list = Dir.glob(File.join(INP, seed))

  puts "- #{seed}: #{list.size} entries"

  list.each do |path|
    puts path
    `rsync -azi #{path} #{OUT}`
  end
end

upload_texts("zhwenpg")
upload_texts("paoshu8")
upload_texts("hetushu")
# upload_texts("jx_la")
