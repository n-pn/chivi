require "../shared/bootstrap"

module CV::FixIntros
  extend self

  DEBUG = ARGV.includes?("debug")

  def set!
    total, index = Nvinfo.query.count, 0
    query = Nvinfo.query.order_by(weight: :desc)
    query.each_with_cursor(20) do |nvinfo|
      index += 1
      puts "- [fix_intros] <#{index}/#{total}>".colorize.blue if index % 100 == 0

      yintro = nil

      if ysbook = Ysbook.find({id: nvinfo.ysbook_id})
        yintro = ysbook.bintro.split('\t')
      end

      if yintro && yintro.size > 1
        bintro = yintro
      else
        bintro = fintro = nil

        nvinfo.nvseeds.to_a.each do |nvseed|
          sintro = nvseed.bintro.split('\t')
          fintro ||= sintro

          if decent_intro?(nvseed.sname, sintro, yintro)
            bintro = sintro
            break
          end
        end

        bintro ||= fintro || yintro
      end

      next if bintro.nil?

      if DEBUG
        File.open("tmp/fix_intro.log", "w") do |io|
          io.puts nvinfo.bhash
          bintro.join(io, '\n')
        end
      end

      nvinfo.set_zintro(bintro.not_nil!, force: true)
      nvinfo.save!
    end
  end

  private def decent_intro?(sname : String, bintro : Array(String), yintro : Array(String)?)
    case sname
    when "hetushu", "zhwenpg"
      bintro.size > 0
    else
      return false if bintro.empty?
      yintro ? yintro.includes?(bintro[0]) : bintro.size > 1
    end
  end
end

CV::FixIntros.set!
