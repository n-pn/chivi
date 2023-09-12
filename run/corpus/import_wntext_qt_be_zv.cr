ENV["CV_ENV"] = "production"
require "../../src/zroot/corpus"

WN_TXT_DIR = "var/wnapp/chtext"
WN_VTL_DIR = "var/wnapp/chtran"

def import(wn_id : String)
  files = Dir.glob("#{WN_VTL_DIR}/#{wn_id}/*.bzv.txt")
  puts "- #{wn_id}: #{files.size} files"

  return if files.empty?

  corpus = ZR::Corpus.new("nctext/#{wn_id}", "vtran")
  corpus.init_dbs!(false, false, false)

  zline_count = 0
  vdata_count = 0

  files.each_slice(32) do |slice|
    corpus.open_tx do
      slice.each do |vfile|
        zorig = File.basename(vfile, ".bzv.txt")
        txt_path = "#{WN_TXT_DIR}/#{wn_id}/#{zorig}.txt"

        u8_ids, fresh = corpus.add_file!(zorig, fpath: txt_path, to_canon: true)
        zline_count += u8_ids.size if fresh

        lines = File.read_lines(vfile, chomp: true)
        vdata_count += corpus.add_data!("be_zv", u8_ids, lines)
      rescue ex
        puts ex
      end
    end
  end

  puts " imported zlines: #{zline_count}, btrans: #{vdata_count}"
end

Dir.each_child(WN_VTL_DIR) do |wn_id|
  import(wn_id)
end
