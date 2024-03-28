files = Dir.glob("/media/nipin/Check/Storage/RyokoAI_CNNovel125K/*.jsonl")

files.each do |ipath|
  opath = "/mnt/extra/Asset/texts/ibiquw/#{File.basename(ipath)}.zst"
  puts `zstd '#{ipath}' -o '#{opath}' --no-check --rsyncable -T4`
end
