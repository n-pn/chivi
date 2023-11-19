ENV["CV_ENV"] ||= "production"
require "../../src/rdapp/data/rmstem"

File.each_line "var/zroot/must_keep.tsv" do |line|
  next if line.blank?
  sname, sn_id = line.split('\t')

  puts line if sname == "!rengshu.com"
end
