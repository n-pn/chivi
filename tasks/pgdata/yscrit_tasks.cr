require "../shared/yscrit_raw"

module CV
  extend self

  reseed! if ARGV.includes?("reseed")
  update! if ARGV.includes?("update")

  DIR = "_db/yousuu/crits"

  def reseed!
    groups = Dir.children(DIR).sort_by!(&.to_i)

    groups.each do |group|
      puts "[#{group}]"

      files = Dir.glob("#{DIR}/#{group}/*.json")
      files.each do |file|
        crits = YscritRaw.from_book(File.read(file))[:comments]
        crits.each(&.seed!(FileUtil.mtime(file).not_nil!.to_unix))
      rescue err
        puts err
        File.delete(file)
      end
    end
  end

  def update!
    Yscrit.query.order_by(id: :asc).with_nvinfo.each_with_cursor(10) do |yscrit|
      yscrit.fix_vhtml
      yscrit.repl_count = Ysrepl.query.where(yscrit_id: yscrit.id).count.to_i
      yscrit.save!
    end
  end
end
