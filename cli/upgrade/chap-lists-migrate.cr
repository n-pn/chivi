require "../../src/kernel/chap_list"
require "../../src/filedb/*"
require "../../src/_utils/text_util"

INP = "var/appcv/chlists"
OUT = "_db/prime/chdata"

struct SeedList
  getter _indexed, zh_title, vi_title, vi_label, url_slug

  def initialize(sname : String, s_bid : String)
    dir = "#{OUT}/infos/#{sname}/#{s_bid}"
    FileUtils.mkdir_p(dir)

    @_indexed = ValueMap.new("#{dir}/_indexed.tsv")
    @zh_title = ValueMap.new("#{dir}/zh_title.tsv")
    @vi_title = ValueMap.new("#{dir}/vi_title.tsv")
    @vi_label = ValueMap.new("#{dir}/vi_label.tsv")
    @url_slug = ValueMap.new("#{dir}/url_slug.tsv")
  end

  def save!
    @_indexed.save!
    @zh_title.save!
    @vi_title.save!
    @vi_label.save!
    @url_slug.save!
  end
end

input = Dir.glob("#{INP}/**/*.json")

input.each_with_index do |file, idx|
  chlist = ChapList.read!(file)
  puts "\n- <#{idx + 1}/#{input.size}> [#{chlist.seed}:#{chlist.sbid}]".colorize.yellow

  output = SeedList.new(chlist.seed, chlist.sbid)

  chlist.chaps.each_with_index do |chap, index|
    output._indexed.upsert!(index.+(1).*(10).to_s, chap.scid, mtime: 0)
    output.zh_title.upsert!(chap.scid, "#{chap.zh_label}  #{chap.zh_title}", mtime: 0)
    output.vi_title.upsert!(chap.scid, chap.vi_title, mtime: 0)
    output.vi_label.upsert!(chap.scid, chap.vi_label, mtime: 0) if chap.vi_label != "Chính văn"
    output.url_slug.upsert!(chap.scid, chap.url_slug, mtime: 0)
  end

  output.save!
end
