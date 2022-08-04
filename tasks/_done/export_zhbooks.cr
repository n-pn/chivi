require "../src/_init/zhbook_init"

require "./nvseed/zhinfo_data"

module CV
  extend self

  INP_DIR = "var/zhinfos"

  def generate(sname : String)
    dir = File.join(INP_DIR, sname)
    parts = Dir.children(dir).reject!(&.includes?(".")).sort_by!(&.to_i)

    table = ZhbookInit::Table.new(sname)

    parts.each_with_index(1) do |part, i|
      puts "[#{sname}] #{i}/#{parts.size}"
      generate(sname, File.join(dir, part), table)
    end
  end

  def generate(sname : String, w_dir : String, table : ZhbookInit::Table)
    input = ZhinfoData.new(sname, w_dir)

    input._index.data.each do |snvid, bindex|
      puts "#{snvid} - #{bindex.btitle} - #{bindex.author}"
      entry = ZhbookInit::Entry.new(snvid, bindex.btitle, bindex.author)

      entry.genres = input.genres[snvid]?.try(&.join(',')) || ""
      entry.bintro = input.bintro[snvid]?.try(&.join('\n')) || ""
      entry.bcover = input.bcover[snvid]? || ""

      if status = input.status[snvid]?
        entry.status_str = status.rawstr
        entry.status_int = status.status
      end

      if update = input.mftime[snvid]?
        entry.update_str = update.rawstr
        entry.update_int = update.mftime
      end

      if chdata = input.chsize[snvid]?
        entry.chap_total = chdata.chap_count
        entry.last_schid = chdata.last_schid
      end

      table.upsert(entry, bindex.stime)
    end
  end

  ARGV.each do |sname|
    generate(sname)
  end
end
