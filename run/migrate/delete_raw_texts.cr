require "colorize"
require "../../src/rdapp/data/czdata"

TXT_DIR = "var/texts"
DB3_DIR = "var/stems"

def check_repo(sroot : String)
  zrepo = RD::Czdata.db(sroot)
  zdata = zrepo.open_ro do |db|
    db.query_all "select ch_no, cksum from czinfos where cksum <> 0", as: {Int32, Int64}
  end

  zdata = zdata.map { |ch_no, cksum| "#{ch_no}-#{ChapUtil.cksum_to_s(cksum)}" }.to_set
  files = Dir.glob("#{TXT_DIR}/#{sroot}/*.raw.txt")

  saved = files.select do |file|
    ch_no, cksum, _part = File.basename(file, ".raw.txt").split('-')
    zdata.includes?("#{ch_no}-#{cksum}")
  end

  puts "#{sroot}: total: #{files.size}, zdata: #{zdata.size}, saved: #{saved.size}"
end

sname = "rm!piaotia.com"

Dir.each_child("#{TXT_DIR}/#{sname}") do |sn_id|
  check_repo "#{sname}/#{sn_id}"
end
