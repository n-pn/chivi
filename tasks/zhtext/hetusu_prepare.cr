require "../../src/_util/site_link"
require "../../src/_data/ch_repo"

def save_queue(sname : String, s_bid : Int32)
  repo = CV::ChRepo.new(sname, s_bid)
  chaps = repo.empty_chaps
  return if chaps.empty?

  out_path = "var/chaps/.html/#{sname}/#{s_bid}.tsv"

  out_file = File.open(out_path, "w")

  chaps.each do |chap|
    out_file << CV::SiteLink.text_url(sname, s_bid, chap.s_cid)
    out_file << '\t' << "#{chap.s_cid}.html" << '\n'
  end

  out_file.close
  puts "- saved to: #{out_path}, entries: #{chaps.size}"
end

1.upto(6218) do |s_bid|
  save_queue("hetushu", s_bid)
end
