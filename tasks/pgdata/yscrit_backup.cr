require "./_shared"

module CV::YscritBackup
  extend self

  DIR = "var/yousuu/yscrits"

  class_getter missing = 0
  class_getter recover = 0

  ZTEXT = {} of String => Tabkv
  INFOS = {} of String => Tabkv

  def load_ztext_map(group)
    ZTEXT[group] ||= Tabkv.new("#{DIR}/#{group}-ztext.tsv")
  end

  def load_infos_map(group)
    INFOS[group] ||= Tabkv.new("#{DIR}/#{group}-infos.tsv")
  end

  def save!(crit : Yscrit)
    ycrid = crit.origin_id
    group = ycrid[0..3]

    ztext_map = load_ztext_map(group)
    infos_map = load_infos_map(group)

    old_ztext = ztext_map.fval(ycrid)

    if crit.ztext != "请登录查看评论内容"
      lines = format_ztext(crit.ztext)
      @@recover += 1 if old_ztext == "$$$"
    elsif !old_ztext
      lines = ["$$$"]
      @@missing += 1
    end

    infos = [
      crit.ysbook_id, crit.ysuser.id, crit.ysuser.zname,
      crit.stars, crit.like_count, crit.repl_count,
      crit.created_at.to_unix, crit.mftime,
    ]

    ztext_map.set!(ycrid, lines) if lines
    infos_map.set(ycrid, infos)
  end

  def format_ztext(ztext : String) : Array(String)
    ztext.split("\n").map(&.strip).reject(&.empty?)
  end

  def run!(fresh = false)
    query = Yscrit.query.order_by(id: :asc).with_ysuser
    query.each_with_cursor(20) { |crit| save!(crit) }

    ZTEXT.each_value(&.save!(dirty: false))
    INFOS.each_value(&.save!(dirty: false))

    File.open("tmp/yscrits-backup-log.txt", "a") do |io|
      io.puts("backup:: missing: #{@@missing}, recover: #{@@recover}")
    end
  end
end

CV::YscritBackup.run!
