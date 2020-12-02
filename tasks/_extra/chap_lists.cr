require "../../src/kernel/mapper/value_map"
# require "../../src/_oldcv/_utils/text_util"
require "../../src/_oldcv/kernel/models/chap_list"

INP = "_db/_oldcv/chlists"
OUT = "_db/_extra/chlist"

struct SeedList
  getter _indexed, zh_title, vi_title, vi_label, url_slug

  def initialize(sname : String, s_bid : String)
    dir = "#{OUT}/infos/#{sname}/#{s_bid}"
    FileUtils.mkdir_p(dir)

    @_indexed = Chivi::ValueMap.new("#{dir}/_indexed.tsv")
    @zh_title = Chivi::ValueMap.new("#{dir}/zh_title.tsv")
    @vi_title = Chivi::ValueMap.new("#{dir}/vi_title.tsv")
    @vi_label = Chivi::ValueMap.new("#{dir}/vi_label.tsv")
    @url_slug = Chivi::ValueMap.new("#{dir}/url_slug.tsv")
  end

  def save!
    @_indexed.save!
    @zh_title.save!
    @vi_title.save!
    @vi_label.save!
    @url_slug.save!
  end
end

def extract_list(seed = "zhwenpg")
  puts "[-- #{seed} --]".colorize.cyan.bold
  input = Dir.glob("#{INP}/**/#{seed}.json")

  input.each_with_index do |file, idx|
    chlist = Oldcv::ChapList.read!(file)
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
end

seeds = ARGV.empty? ? Dir.children(OUT) : ARGV
seeds.each { |seed| extract_list(seed) }
