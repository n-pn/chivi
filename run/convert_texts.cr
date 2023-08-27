require "../src/wnapp/data/chinfo"
require "../src/wnapp/data/wnseed"

class Chtext
  getter wc_base : String

  WN_DIR = "var/wnapp/chtext"
  ZH_DIR = "var/zroot/wntext"

  V0_DIR = "var/texts/rgbks"

  def initialize(@stem : WN::Wnsterm, @chap : WN::Chinfo)
    @wc_base = "#{WN_DIR}/#{stem.wn_id}/#{chap.ch_no}"
    chap.spath = "#{stem.sname}/#{stem.s_bid}/#{chap.ch_no}" if chap.spath.empty?
  end

  def wn_path(p_idx : Int32, cksum : String = @chap.cksum)
    "#{@wc_base}-#{cksum}-#{p_idx}.txt"
  end

  def zh_path(cksum : String = @chap.cksum)
    "#{ZH_DIR}/#{@chap.spath}-#{cksum}-#{@chap.ch_no}.txt"
  end

  def file_exists?
    !@chap.cksum.empty? && File.file?(self.wn_path(p_idx: @chap.psize))
  end

  def import_existing! : String?
    files = [] of String

    if @stem.sname[0] != '!'
      spath = "#{@stem.sname}/#{@stem.wn_id}/#{@chap.ch_no}"
      files << "#{V0_DIR}/#{spath}.gbk"
      files << "#{V0_DIR}/#{spath}.txt"
    end

    files << "#{V0_DIR}/#{@chap.spath}.gbk"
    files << "#{V0_DIR}/#{@chap.spath}.txt"

    return unless file = files.find { |x| File.file?(x) }
    # Log.info { "found: #{file}".colorize.green }

    encoding = file.ends_with?("gbk") ? "GB18030" : "UTF-8"
    ztext = File.read(file, encoding: encoding, invalid: :skip)

    if ztext.blank?
      log_file = "#{LOG_DIR}/#{@stem.sname}-missing.log"
      out_line = "#{@stem.s_bid}\t#{@chap.ch_no}\t#{@chap.spath}"

      File.open(log_file, "a", &.puts(out_line))
      File.delete(file)

      return nil
    end

    self.save_text!(ztext: ztext)
  end

  def save_text!(ztext : String)
    lines = [] of String

    ztext.each_line do |line|
      lines << TextUtil.canon_clean(line) unless line.blank?
    end

    title = lines.shift
    parts, sizes, cksum = ChapUtil.split_rawtxt(lines: lines, title: title)
    save_text!(parts, cksum: cksum, sizes: sizes)
  end

  def save_text!(parts : Array(String), cksum : UInt32,
                 sizes : Array(Int32) = parts.map(&.size))
    @chap.cksum = ChapUtil.cksum_to_s(cksum)
    @chap.sizes = sizes.map(&.to_s).join(' ')

    parts.each_with_index do |cpart, index|
      save_path = self.wn_path(index)

      File.open(save_path, "w") do |file|
        file << parts[0]
        file << '\n' << cpart if index > 0
      end
    end

    self.save_backup!(parts)
    @chap.cksum
  end

  private def save_backup!(parts : Array(String), cksum : String = @chap.cksum)
    zh_path = self.zh_path(cksum)
    return if File.file?(zh_path)

    dirname = File.dirname(zh_path)
    Dir.mkdir_p(dirname)

    File.open(zh_path, "w") { |file| parts.join(file, "\n\n") }
  end
end

def convert(wnstem : WN::Wnsterm)
  chlist = WN::Chinfo.get_all(db: wnstem.chap_list)
  puts "- [#{wnstem.sname}/#{wnstem.s_bid}]: #{chlist.size} files"

  output = [] of WN::Chinfo

  chlist.each do |chinfo|
    chtext = Chtext.new(wnstem, chinfo)
    next if chtext.file_exists?

    if cksum = chtext.import_existing!
      output << chinfo
    else
      puts "-- #{wnstem.s_bid}/#{chinfo.ch_no} is missing!".colorize.red
    end
  end

  return if output.empty?

  puts "-- #{output.size} converted!"

  wnstem.chap_list.open_tx do |db|
    output.each(&.upsert!(db: db))
  end
end

LOG_DIR = "var/zroot/logged"

def convert(sname : String)
  log_file = "#{LOG_DIR}/#{sname}-convert.log"

  checked = Set(String).new
  checked.concat(File.read_lines(log_file)) if File.file?(log_file)

  stems = WN::Wnsterm.get_all(sname, &.<< "where sname = $1")
  stems.each do |stem|
    next if checked.includes?(stem.s_bid)
    convert(stem)
    File.open(log_file, "a", &.puts(stem.s_bid))
  rescue ex
    puts ex.colorize.red
  end
end

snames = ARGV.reject(&.starts_with?('-'))
snames = Dir.children("var/zroot/wnchap") if snames.empty?

snames.select!(&.starts_with?('@')) if ARGV.includes?("--users")
snames.select!(&.starts_with?('!')) if ARGV.includes?("--globs")

snames.each { |sname| convert sname }
