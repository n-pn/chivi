require "./_shared"

module CV::YscritBackup
  extend self

  class_getter count = 0

  def save!(crit : Yscrit)
    ycrid = crit.origin_id
    group = ycrid[0..3]

    File.open("#{YSCRIT_DIR}/#{group}-ztext.tsv", "a") do |io|
      io << "\n" << ycrid << '\t'
      format_ztext(crit.ztext).join(io, '\t')
    end

    File.open("#{YSCRIT_DIR}/#{group}-infos.tsv", "a") do |io|
      io << "\n"

      {
        ycrid,
        crit.ysbook_id,
        crit.ysuser.id,
        crit.ysuser.zname,
        crit.stars,
        crit.created_at.to_unix,
        crit.mftime,
        crit.like_count,
        crit.repl_count,
      }.join(io, "\t")
    end
  end

  def format_ztext(ztext : String) : Array(String)
    if ztext == "请登录查看评论内容"
      @@count += 1
      return [] of String
    end

    ztext.split("\n").map(&.strip).reject(&.empty?)
  end

  def run!(fresh = false)
    Yscrit.query.order_by(id: :asc).with_ysuser.each_with_cursor(20) { |crit| save!(crit) }
    puts "- hidden body: #{@@count}"
  end
end

CV::YscritBackup.run!
