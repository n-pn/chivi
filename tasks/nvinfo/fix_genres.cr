require "../shared/seed_util"

class CV::FixGenres
  def set!
    total, index = Nvinfo.query.count, 0
    query = Nvinfo.query.order_by(weight: :desc)
    query.each_with_cursor(20) do |nvinfo|
      index += 1
      puts "- [fix_genres] <#{index}/#{total}>".colorize.blue if index % 100 == 0

      input = [] of Int32

      input.concat get_genres("yousuu", nvinfo.ysbook_id) if nvinfo.ysbook_id > 0
      nvinfo.nvseeds.each { |x| input.concat get_genres(x.sname, x.snvid) }

      tally = input.tally.to_a.sort_by(&.[1].-)
      keeps = tally.reject(&.[1].< 2)

      output = keeps.empty? ? tally.map(&.[0]).first(2) : keeps.map(&.[0]).first(3)
      output.reject!(&.== 0) if output.size > 1

      nvinfo.igenres = output
      nvinfo.save!
    end
  end

  def get_genres(sname : String, snvid : String) : Array(Int32)
    genres = genres_map(sname).get(snvid) || [] of String
    Bgenre.zh_map_ids(genres)
  end

  @cache = {} of String => TsvStore

  def genres_map(sname : String)
    @cache[sname] ||= begin
      file = "_db/zhbook/#{sname}/genres.tsv"
      TsvStore.new(file, mode: 1)
    end
  end
end

worker = CV::FixGenres.new
worker.set!
