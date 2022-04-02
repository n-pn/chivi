require "tabkv"
require "file_utils"
require "../shared/bootstrap"
require "../shared/yscrit_raw"

module CV::YscritSeed
  extend self

  DIR = "var/yscrits"
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
      File.open("tmp/yscrits-healthy.txt", "a", &.puts(ycrid)) if unmapped
    elsif unmapped
      lines = ["$$$"]
      @@count += 1
      File.open("tmp/yscrits-missing.txt", "a", &.puts(ycrid))
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
    File.open("tmp/yscrits-invalid-json.txt", "a", &.puts(file))
  end

  def init!(root : String = "_db/yousuu/crits")
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

    File.open("tmp/yscrits-log.txt", "a", &.puts("#{root}: #{@@count}"))
  end

  def seed!
    info_maps = Dir.glob("#{DIR}/*-infos.tsv")

    info_maps.each do |infos_file|
      ztext_file = infos_file.sub("infos", "ztext")

      infos_map = Tabkv.new(infos_file)
      ztext_map = Tabkv.new(ztext_file)

      seed_file!(infos_map, ztext_map)
    end
  end

  def seed_file!(infos_map : Tabkv, ztext_map : Tabkv)
    infos_map.data.each do |ycrid, infos|
      mtime = infos[6].to_i64

      yscrit_id = ycrid[12..].to_i64(base: 16)
      ysbook_id = infos[0].to_i64

      yscrit = Yscrit.get!(yscrit_id, Time.unix(mtime))
      next unless nvinfo = Nvinfo.find({ysbook_id: ysbook_id})
      next unless ysuser = Ysuser.upsert!(infos[2])

      yscrit.ysuser = ysuser
      yscrit.nvinfo_id = nvinfo.id

      yscrit.origin_id = ycrid
      bhash = nvinfo.bhash

      yscrit.stars = infos[3].to_i
      yscrit.like_count = infos[4].to_i
      yscrit.repl_count = infos[5].to_i

      yscrit.utime = mtime

      if ztext = ztext_map.get(ycrid)
        File.write("tmp/yscrits-log.txt", ["#{bhash} #{ycrid}"].concat(ztext).join("\n"))

        yscrit.ztext = ztext.join("\n")
        yscrit.vhtml = SeedUtil.cv_ztext(ztext, bhash)
      end

      yscrit.save!
    rescue
      line = [ycrid].concat(infos).join("\t")
      File.open("tmp/yscrits-err.txt", "a", &.puts(line))
    end
  end

  def test_cv!
    engine = MtCore.generic_mtl("combine")

    text_maps = Dir.glob("#{DIR}/*-ztext.tsv")
    text_maps.each_with_index(1) do |file, idx|
      puts "- <#{idx}> #{file}"
      map = Tabkv.new(file)

      map.data.each_value do |lines|
        lines.each do |line|
          File.write("tmp/yscrits-mtl.txt", line)
          engine.cv_plain(line)
        end
      end
    end
  end
end

CV::YscritSeed.init! if ARGV.includes?("init")
CV::YscritSeed.seed! if ARGV.includes?("seed")
CV::YscritSeed.test_cv! if ARGV.includes?("test_cv")
