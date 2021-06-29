require "file_utils"
require "../src/tsvfs/value_map"
require "../src/appcv/filedb/ch_info"

class CV::Fixer
  DIR = "_db/chseed"

  def initialize(@sname : String)
    @map = ValueMap.new("_db/zhbook/#{@sname}/chsize.tsv")
    @rdir = File.join(DIR, @sname)
  end

  def fix_all!
    input = Dir.children(@rdir).map do |snvid|
      bdir = File.join(@rdir, snvid)
      {snvid, bdir, File.join(bdir, "_id.tsv")}
    end

    input.each_with_index(1) do |(snvid, bdir, file), idx|
      next if @map.has_key?(snvid)

      if File.exists?(file)
        chap_count, last_snvid = fix_file(file)
        @map.set!(snvid, [chap_count.to_s, last_snvid])
      else
        ::FileUtils.rm_rf(bdir)
      end

      if idx % 10 == 0
        puts "- [#{idx}/#{input.size}/#{@sname}]: #{snvid}"
        @map.save!
      end
    rescue err
      puts file, err.message

      if RmUtil.remote?(@sname)
        chinfo = ChInfo.new("-", @sname, snvid.not_nil!)
        _, chap_count, last_snvid = chinfo.update!
        @map.set!(snvid.not_nil!, [chap_count.to_s, last_snvid])
        next
      end

      print "what do (r: redo, d: delete, c: exit, g: generate): "
      case gets
      when "r"
        chap_count, last_snvid = fix_file(file.not_nil!)
        @map.set!(snvid.not_nil!, [chap_count.to_s, last_snvid])
      when "d"
        File.delete(file.not_nil!)
      when "c"
        exit(0)
      end
    end

    @map.save!
  end

  def fix_file(file : String) : {Int32, String}
    res = [] of String

    lines = File.read_lines(file)
    lines.each_with_index(1) do |line, idx|
      next if line.strip.empty?
      vals = line.split('\t')

      case vals.size
      when 1, 2
        raise "invalid line <#{line}>: wrong length"
      when 3
        res << vals.join('\t')
      when 4
        chidx = vals.shift
        raise "invalid line <#{line}>: index do not match" if chidx != idx.to_s
        res << vals.join('\t')
      end
    end

    File.write(file, res.join('\n'))

    last_schid = res.last.split('\t').first
    {res.size, last_schid}
  end

  def self.run!
    Dir.children(DIR).each { |sname| new(sname).fix_all! }
  end
end

CV::Fixer.run!
