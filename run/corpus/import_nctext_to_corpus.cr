require "../../src/zroot/corpus"

WN_TXT_DIR = "var/wnapp/chtext"

def import(wn_id : String)
  files = Dir.glob("#{WN_TXT_DIR}/#{wn_id}/*.txt")
  puts "- #{wn_id}: #{files.size} files"
  return if files.empty?

  corpus = ZR::Corpus.new("nctext/#{wn_id}")
  corpus.init_dbs!(false, false, true)

  zline_count = 0

  corpus.open_tx do
    files.each do |zfile|
      zorig = File.basename(zfile, ".txt")
      u8_ids, fresh = corpus.add_file!(zorig, fpath: zfile, to_canon: true)
      zline_count += u8_ids.size if fresh
    rescue ex
      puts ex
    end
  end

  puts " imported zlines: #{zline_count}"
end

Dir.each_child(WN_TXT_DIR) do |wn_id|
  import(wn_id)
end
