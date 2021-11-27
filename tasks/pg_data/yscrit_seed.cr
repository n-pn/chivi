require "tabkv"
require "file_utils"
require "../shared/bootstrap"
require "../shared/yscrit_raw"

module CV::YscritSeed
  extend self

  DIR = "var/yousuu/yscrits"
  FileUtils.mkdir_p(DIR)

  class_getter count = 0

  ZTEXT = {} of String => Tabkv
  INFOS = {} of String => Tabkv

  def load_ztext_map(group)
    ZTEXT[group] ||= Tabkv.new("#{DIR}/#{group}-ztext.tsv")
  end

  def load_infos_map(group)
    INFOS[group] ||= Tabkv.new("#{DIR}/#{group}-infos.tsv")
  end

  def save!(crit : YscritRaw::Json)
    ycrid = crit._id
    group = ycrid[0..3]

    ztext_map = load_ztext_map(group)
    infos_map = load_infos_map(group)

    unmapped = !ztext_map.fval(ycrid)

    if crit.ztext != "请登录查看评论内容"
      lines = format_ztext(crit.ztext)
      File.open("var/yousuu/yscrits-healthy.txt", "a", &.puts(ycrid)) if unmapped
    elsif unmapped
      lines = ["$$$"]
      @@count += 1
      File.open("var/yousuu/yscrits-missing.txt", "a", &.puts(ycrid))
    end

    ztext_map.set!(ycrid, lines) if lines

    infos = [
      crit.book._id, crit.user._id, crit.user.name,
      crit.stars, crit.like_count, crit.repl_count,
      crit.created_at.to_unix, crit.updated_at.to_unix,
    ]

    infos_map.set!(ycrid, infos)
  end

  def format_ztext(ztext : String) : Array(String)
    ztext.split("\n").map(&.strip).reject(&.empty?)
  end

  def save_json!(file : String)
    # puts "- #{file}"
    data = File.read(file)
    crits = YscritRaw::Json.parse_list(data)
    crits.each { |crit| save!(crit) }
  rescue
    puts file
    File.open("var/yousuu/yscrits-invalid-json.txt", "a", &.puts(file))
  end

  def init!(root : String)
    @@count = 0

    Dir.children(root).each do |group|
      dir = File.join(root, group)
      files = Dir.glob("#{dir}/*.json")
      files.each { |file| save_json!(file) }

      # ZTEXT.each_value(&.save!)
      # INFOS.each_value(&.save!)
    end

    ZTEXT.each_value(&.save!(dirty: false))
    INFOS.each_value(&.save!(dirty: false))

    File.open("var/yousuu/yscrits-log.txt", "a", &.puts("#{root}: #{@@count}"))
  end
end

CV::YscritSeed.init!("_db/yousuu/crits.old")
CV::YscritSeed.init!("_db/yousuu/crits")
