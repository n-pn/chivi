require "../shared/ysrepl_raw"

module CV
  extend self

  reseed! if ARGV.includes?("reseed")
  update! if ARGV.includes?("update")

  DIR   = "_db/yousuu/repls"
  PURGE = ARGV.includes?("--purge")

  def reseed!
    groups = Dir.children(DIR).sort!

    groups.each do |group|
      puts "[#{group}]"

      files = Dir.glob("#{DIR}/#{group}/*.json")

      files.each do |file|
        repls, _ = YsreplRaw.from_list(File.read(file))
        stime = FileUtil.mtime_int(file)
        repls.each(&.seed!(stime))
      rescue err
        puts [err, file]
        File.delete(file) if PURGE
      end
    end
  end

  def update!
    Ysrepl.query.order_by(id: :asc)
      .with_yscrit(&.with_nvinfo)
      .each_with_cursor(20) do |ysrepl|
        ysrepl.tap(&.fix_vhtml).save!
      end
  end
end
