require "./../shared/seed_data"

module CV::FixIntros
  extend self

  def set!
    total, index = Nvinfo.query.count, 0
    query = Nvinfo.query.order_by(weight: :desc)
    query.each_with_cursor(20) do |nvinfo|
      index += 1
      puts "- [fix_intros] <#{index}/#{total}>".colorize.blue if index % 100 == 0

      yintro = bintro = fintro = nil.as(Array(String)?)

      nvinfo.ysbooks.each { |x| yintro = get_intro("yousuu", x.id.to_s) }
      nvinfo.zhbooks.to_a.each do |x|
        bintro = get_intro(x.sname, x.snvid)
        break if decent_intro?(x.sname, bintro)
        fintro ||= bintro
      end

      bintro ||= yintro || fintro
      next if bintro.nil?

      # File.open("tmp/fix_intro.log", "a") do |io|
      #   io << nvinfo.bhash
      #   bintro.join(io, "\t")
      #   io << "\n"
      # end

      nvinfo.set_zintro(bintro.not_nil!.join("\n"), force: true)
      nvinfo.save!
    end
  end

  @@seeds = {} of String => SeedData

  def seed_data(sname) : SeedData
    @@seeds[sname] ||= SeedData.new(sname)
  end

  def get_intro(sname : String, snvid : String) : Array(String)
    seed_data(sname).get_intro(snvid)
  end

  private def decent_intro?(sname : String, bintro : Array(String))
    case sname
    when "hetushu", "zhwenpg" then bintro.size > 0
    else                           bintro.size > 1
    end
  end
end

CV::FixIntros.set!
