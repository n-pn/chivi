require "../shared/ysbook_raw"
require "../shared/nvinfo_util"

module CV
  INP_DIR = "_db/yousuu/infos"

  FORCE = ARGV.includes?("-f")

  def self.run!
    groups = Dir.children(INP_DIR).sort_by(&.to_i)

    groups.each do |group|
      dir = File.join(INP_DIR, group)
      Dir.each_child(dir) do |child|
        file = File.join(dir, child)

        next unless input = YsbookRaw.parse_file(file)
        stime = NvinfoUtil.mtime(file).not_nil!

        input.seed!(stime, force: FORCE)
      rescue err
        puts err
      end

      NvinfoUtil.print_stats("yousuu/#{group}/#{groups.size}")
    end
  end

  run!
end
