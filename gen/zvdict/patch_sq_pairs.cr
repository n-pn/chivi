ENV["MT_DIR"] ||= "/2tb/app.chivi/var/mtdic"

require "../../src/mt_ai/data/sq_pair"

def import(tsv_path : String)
  dname = File.basename(tsv_path, "_pair.tsv")
  items = File.read_lines(tsv_path).reject!(&.blank?).map do |line|
    MT::SqPair.new(dname, line.split('\t'))
  end

  puts "#{tsv_path}: #{items.size}"
  MT::SqPair.db.open_tx { |db| items.each(&.upsert!(db: db)) }
end

start = Time.monotonic

DIR = "/2tb/var.chivi/mtdic/mt_ai"

import "#{DIR}/v_c_pair.tsv"
import "#{DIR}/m_n_pair.tsv"

puts Time.monotonic - start
