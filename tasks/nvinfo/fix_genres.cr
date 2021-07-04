require "../shared/seed_util"

class CV::FixGenres
  def fix!
    total, index = Cvbook.query.count, 0
    query = Cvbook.query.with_ysbooks.with_zhbooks.order_by(weight: :desc)
    query.each_with_cursor(10) do |cvbook|
      index += 1
      puts "- [fix_covers] <#{index}/#{total}>".colorize.blue if index % 100 == 0

      input = [0]
      cvbook.ysbooks.each { |x| input.concat get_genres("yousuu", x.id.to_s) }
      cvbook.zhbooks.each { |x| input.concat get_genres(x.sname, x.snvid) }

      tally = input.tally.to_a.sort_by(&.[1].-)
      keeps = tally.reject(&.[1].< 2)

      output = keeps.empty? ? tally.map(&.[0]).first(2) : keeps.map(&.[0]).first(3)
      output.reject!(&.== 0) if output.size > 1

      cvbook.bgenre_ids = output
      cvbook.save!
    end
  end

  def get_genres(sname : String, snvid : String) : Array(Int32)
    genres = genres_map(sname).get(snvid) || [] of String
    Bgenre.zh_map_ids(genres)
  end

  @cache = {} of String => ValueMap

  def genres_map(sname : String)
    @cache[sname] ||= begin
      file = "_db/zhbook/#{sname}/genres.tsv"
      ValueMap.new(file, mode: 1)
    end
  end
end

worker = CV::FixGenres.new
worker.fix!
