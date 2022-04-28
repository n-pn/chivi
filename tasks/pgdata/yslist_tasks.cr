require "../shared/yslist_raw"
require "../shared/nvinfo_util"

module CV
  def self.reseed!
    Dir.glob("_db/yousuu/list-infos/*.json") do |file|
      input = YslistRaw.from_info(File.read(file))
      stime = NvinfoUtil.mtime(file).not_nil!

      input.seed!(stime)
    rescue err
      puts err
    end
  end

  def self.update!
    Yslist.query.each do |yslist|
      book = yslist.nvinfos.to_a

      genres = book.flat_map(&.vgenres)
      yslist.genres = genres.tally.to_a.sort_by!(&.[1].-).map(&.[0])

      yslist.covers = book.sort_by(&.weight.-).first(3).map(&.bcover)

      yslist.set_name(yslist.zname)
      yslist.set_desc(yslist.zdesc)

      yslist.save!
    end
  end

  reseed! if ARGV.includes?("reseed")
  update! if ARGV.includes?("update")
end
