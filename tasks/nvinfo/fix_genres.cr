require "../shared/bootstrap"

class CV::FixGenres
  def set!
    total, index = Nvinfo.query.count, 0
    query = Nvinfo.query.order_by(weight: :desc)
    query.each_with_cursor(20) do |nvinfo|
      index += 1
      puts "- [fix_genres] <#{index}/#{total}>".colorize.blue if index % 100 == 0

      input = [] of Int32

      if ysbook = Ysbook.get(nvinfo.ysbook_id)
        input.concat GenreMap.map_int(ysbook.bgenre.split('\t'))
      end

      nvinfo.nvseeds.each do |nvseed|
        input.concat GenreMap.map_int(nvseed.bgenre.split('\t'))
      end

      tally = input.tally.to_a.sort_by(&.[1].-)
      keeps = tally.reject(&.[1].< 2)

      output = keeps.empty? ? tally.map(&.[0]).first(2) : keeps.map(&.[0]).first(3)
      output.reject!(&.== 0) if output.size > 1

      nvinfo.igenres = output
      nvinfo.save!
    end
  end
end

worker = CV::FixGenres.new
worker.set!
