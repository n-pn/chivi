require "json"

INP = "_db/prime/chdata/texts"
OUT = "deploy@ssh.chivi.xyz:www/chivi/#{INP}"

def upload_texts(seed)
  # TODO: skip low rating books

  inp_dir = File.join(INP, seed)
  folders = Dir.children(inp_dir)
  puts "- #{seed}: #{folders.size} folders"

  folders.each_with_index do |folder, idx|
    files_count = Dir.children(File.join(inp_dir, folder)).size

    puts "-- <#{idx + 1}/#{folders.size}> [#{seed}/#{folder}]: #{files_count} files"
    `rsync -aziI --no-p "#{inp_dir}/#{folder}" #{OUT}/#{seed}`
  end
end

upload_texts("zhwenpg")
upload_texts("hetushu")
upload_texts("paoshu8")
# upload_texts("jx_la")
