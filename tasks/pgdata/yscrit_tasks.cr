require "../shared/yscrit_raw"

module CV
  extend self

  reseed! if ARGV.includes?("reseed")
  update! if ARGV.includes?("update")
  restore! if ARGV.includes?("restore")

  PURGE = ARGV.includes?("--purge")

  def reseed!
    reseed!("_db/yousuu/crits-by-list", type: :list)
    reseed!("_db/yousuu/crits", type: :book)
  end

  def reseed!(dir : String, type = :book)
    dirs = Dir.children(dir)
    dirs.sort_by!(&.to_i) if type == :book

    dirs.each_with_index(1) do |dirname, idx|
      puts "- <#{idx}/#{dirs.size}> [#{dirname}]"
      files = Dir.glob("#{dir}/#{dirname}/*.json")

      files.each do |file|
        crits, _ = YscritRaw.from_json(File.read(file), type)
        stime = FileUtil.mtime_int(file)
        crits.each(&.seed!(stime))
      rescue err
        puts [err, file]
        File.delete(file) if PURGE
      end
    end
  end

  def update!
    Yscrit.query.order_by(id: :asc).with_nvinfo.each_with_cursor(20) do |yscrit|
      yscrit.fix_vhtml
      yscrit.fix_vtags

      yscrit.repl_count = Ysrepl.query.where(yscrit_id: yscrit.id).count.to_i

      yscrit.fix_sort!
      yscrit.save!
    end
  end

  def restore!
    dir = "var/ysinfos/yscrits"

    Dir.glob("#{dir}/*-ztext.tsv") do |file|
      target = Tabkv(Array(String)).new(file)
      target.data.each do |y_cid, bintro|
        next if bintro == ["$$$"]
        next unless yscrit = Yscrit.find({origin_id: y_cid})

        yscrit.set_ztext(bintro.join("\n"))
        yscrit.save!
      end
    end
  end
end
