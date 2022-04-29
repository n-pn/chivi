require "../shared/yslist_raw"
require "../shared/nvinfo_util"

module CV
  PURGE = ARGV.includes?("--purge")

  def self.reseed!
    Dir.glob("_db/yousuu/lists/*.json") do |file|
      input = YslistRaw.from_info(File.read(file))
      stime = NvinfoUtil.mtime(file).not_nil!

      input.seed!(stime)
    rescue err
      puts [err, file]
      File.delete(file) if PURGE
    end
  end

  def self.update!
    Yslist.query.each do |yslist|
      binfos = yslist.nvinfos.to_a

      genres = binfos.flat_map(&.vgenres).reject(&.== "Loại khác")
      yslist.genres = genres.tally.to_a.sort_by!(&.[1].-).map(&.[0]).first(10)

      yslist.covers = binfos.sort_by(&.weight.-).first(3).map(&.bcover)

      yslist.fix_vname
      yslist.fix_vdesc
      yslist.fix_sort!

      yslist.save!
    end
  end

  reseed! if ARGV.includes?("reseed")
  update! if ARGV.includes?("update")
end
