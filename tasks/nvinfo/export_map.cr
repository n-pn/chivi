require "../shared/bootstrap"

module CV
  total, index = Cvbook.query.count, 0
  query = Cvbook.query.order_by(weight: :desc)

  lookup = {} of String => Int64
  zhseed = [] of Array(String)

  query.each_with_cursor(20) do |book|
    index += 1
    puts "- [export_map] <#{index}/#{total}>".colorize.blue if index % 100 == 0

    {book.bhash, book.bslug, "#{book.htslug}-#{book.bhash}"}.each do |slug|
      lookup[slug] ||= book.id
    end

    next unless seed = book.zhbooks.to_a.sort_by(&.zseed).first?
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
