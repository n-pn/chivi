require "./../shared/seed_data"

def fix_all_entries
  books = CV::Nvinfo.query.order_by(id: :desc).to_a

  books.each_with_index(1) do |nvinfo, index|
    next if nvinfo.id <= 0

    bslug = nvinfo.bslug
    nvinfo.fix_names!
    next unless nvinfo.bslug != bslug
    puts "- <#{index}/#{books.size}> #{bslug} => #{nvinfo.bslug}".colorize.blue
  end
end

def fix_selected(titles : Array(String))
  titles.each do |title|
    query = CV::Nvinfo.query.filter_btitle(title)
    query.each(&.fix_names!)
  end
end

if ARGV.empty?
  fix_all_entries
else
  fix_selected(ARGV)
end
