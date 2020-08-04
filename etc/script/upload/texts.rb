require "json"

DIR = File.join("var", "bookdb", "serials")

INP = File.join("var", "appcv", "chtexts")
OUT= "nipin@ssh.nipin.xyz:web/chivi/var/appcv/chtexts/"

def upload_texts(seed)
  list = Dir.glob(File.join(INP, "*.#{seed}"))

  list.select! do |path|
    ubid = File.basename(path).split(".").first
    info = JSON.parse File.read("#{DIR}/#{ubid}.json")
    info["weight"] > 8000
  rescue => err
    # puts err
  end

  puts "- #{seed}: #{list.size} entries"

  list.each do |path|
    puts path
    `rsync -azi "#{path}" "#{OUT}"`
  end
end

# upload_texts("zhwenpg")
upload_texts("paoshu8")
upload_texts("hetushu")
upload_texts("jx_la")
