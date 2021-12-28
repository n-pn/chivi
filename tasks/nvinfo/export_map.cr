require "../shared/bootstrap"

module CV
  total, index = Nvinfo.query.count, 0
  query = Nvinfo.query.order_by(weight: :desc)

  lookup = {} of String => String
  zhseed = [] of Array(String)

  query.each_with_cursor(20) do |book|
    index += 1
    puts "- [export_map] <#{index}/#{total}>".colorize.blue if index % 100 == 0

    # {book.bhash, book.bslug, "#{book.hslug}-#{book.bhash}"}.each do |slug|
    #   lookup[slug] ||= book.id
    # end

    {book.bhash, "#{book.hslug}-#{book.bhash}", book.hslug, book.vslug}.each do |slug|
      lookup[slug] ||= book.bslug unless slug.empty?
    end

    zseeds = book.zhbooks.to_a.sort_by(&.zseed)
    next unless seed = zseeds.find(&.zseed.> 0) || zseeds.first?
    zhseed << [seed.sname, seed.snvid, book.bhash, book.bslug, book.id.to_s]
  end

  File.open("priv/lookup.tsv", "w") do |f|
    lookup.each do |key, val|
      f.puts "#{key}\t#{val}"
    end
  end

  File.open("priv/zhseed.tsv", "w") do |f|
    zhseed.each do |vals|
      vals.join(f, '\t')
      f.puts
    end
  end
end
