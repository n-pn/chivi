require "../shared/bootstrap"

class CV::FixGenres
  def set!
    total, index = Nvinfo.query.count, 0
    query = Nvinfo.query.order_by(id: :desc)
    query.each_with_cursor(20) do |nvinfo|
      index += 1
      puts "- [fix_genres] <#{index}/#{total}>".colorize.blue if index % 100 == 0

      input = [] of Int32

      if ysbook = Ysbook.find({id: nvinfo.ysbook_id})
        genres = GenreMap.zh_to_vi ysbook.bgenre.split('\t')
        input.concat GenreMap.map_int(genres)
      end

      nvinfo.nvseeds.each do |nvseed|
        genres = GenreMap.zh_to_vi nvseed.bgenre.split('\t')
        input.concat GenreMap.map_int(genres)
      end

      tally = input.reject(&.< 1).tally.to_a.sort_by(&.[1].-)
      keeps = tally.reject(&.[1].< 2)

      output = keeps.empty? ? tally.map(&.[0]).first(2) : keeps.map(&.[0]).first(3)

      nvinfo.update(igenres: output.empty? ? [0] : output)
    end
  end
end

worker = CV::FixGenres.new
worker.set!
