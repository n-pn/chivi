require "./../pgdata/init_nvinfo"

module CV::FixIntros
  extend self

  def set!
    total, index = Nvinfo.query.count, 0
    query = Nvinfo.query.order_by(weight: :desc)
    query.each_with_cursor(20) do |nvinfo|
      index += 1
      puts "- [fix_intros] <#{index}/#{total}>".colorize.blue if index % 100 == 0

      yintro = nil

      nvinfo.ys_snvid.try { |x| yintro = get_intro("yousuu", x.to_s) }

      if yintro && yintro.size > 0
        bintro = yintro
      else
        bintro = fintro = nil

        nvinfo.zhbooks.to_a.each do |x|
          intro = get_intro(x.sname, x.snvid)
          fintro ||= intro

          if decent_intro?(x.sname, intro, yintro)
            bintro = intro
            break
          end
        end

        bintro ||= yintro || fintro
      end

      next if bintro.nil?

      # File.open("tmp/fix_intro.log", "a") do |io|
      #   io << nvinfo.bhash
      #   bintro.join(io, "\t")
      #   io << "\n"
      # end

      nvinfo.set_zintro(bintro.not_nil!, force: true)
      nvinfo.save!
    end
  end

  @@seeds = Hash(String, InitNvinfo).new do |hash, sname|
    hash[sname] = InitNvinfo.new(sname)
  end

  def get_intro(sname : String, snvid : String) : Array(String)
    @@seeds[sname].get_val(:intros, snvid) || [] of String
  end

  private def decent_intro?(sname : String, bintro : Array(String), yintro)
    case sname
    when "hetushu", "zhwenpg"
      bintro.size > 0
    else
      return false if bintro.empty?
      return bintro.size > 1 unless yintro
      yintro.includes?(bintro[0])
    end
  end
end

CV::FixIntros.set!
