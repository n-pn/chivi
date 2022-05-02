require "../shared/bootstrap"

module CV::FixGenres
  extend self

  def fix_all!(redo = false)
    total, index = Nvinfo.query.count, 0
    query = Nvinfo.query.order_by(id: :desc)

    query.each_with_cursor(20) do |nvinfo|
      index += 1
      puts "- [fix_genres] <#{index}/#{total}>".colorize.blue if index % 100 == 0

      zgenres, zlabels = pick_genres(nvinfo, redo)
      nvinfo.set_genres(zgenres, force: true)
      nvinfo.vlabels.concat(GenreMap.zh_to_vi(zlabels)).uniq!
      nvinfo.save!
    end
  end

  def pick_genres(nvinfo : Nvinfo, redo = false)
    if !redo && (cvseed = Nvseed.find(nvinfo.id, 0))
      genres = cvseed.bgenre.split('\t')
      return genres, [] of String unless genres.empty?
    end

    genres = [] of String

    nvinfo.ysbook.try do |ysbook|
      ysbook.bgenre.split('\t') { |x| genres << x << x }
    end

    nvinfo.nvseeds.each do |nvseed|
      next if nvseed.zseed == 0

      nvseed.bgenre.split('\t') do |x|
        genres << x
        genres << x << x if nvseed.sname == "users"
      end
    end

    tally = genres.reject!(&.in?("其他", "")).tally.to_a.sort_by(&.[1].-)
    keeps = tally.reject(&.[1].< 2)

    labels = tally.map(&.[0])
    output = keeps.empty? ? labels : keeps.map(&.[0])

    {output, labels - output}
  end

  fix_all!(redo: ARGV.includes?("--redo"))
end
