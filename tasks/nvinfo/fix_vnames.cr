require "./../shared/bootstrap"

def fix_all_entries
  CV::Author.query.order_by(id: :desc).each do |author|
    author.tap(&.fix_name!).save!
  end

  books = CV::Nvinfo.query.order_by(id: :desc).to_a

  books.each_with_index(1) do |nvinfo, index|
    next if nvinfo.id <= 0

    bslug = nvinfo.bslug
    nvinfo.fix_scores!(nvinfo.voters, nvinfo.voters * nvinfo.rating)
    nvinfo.fix_names!

    next unless nvinfo.bslug != bslug
    puts "- <#{index}/#{books.size}> #{bslug} => #{nvinfo.bslug}".colorize.blue
  end
end

def fix_selected(titles : Array(String))
  titles.each do |title|
    query = CV::Nvinfo.query.filter_btitle(title)
    query.each do |nvinfo|
      nvinfo.fix_names!
      nvinfo.author.tap(&.fix_name!).save!
    end
  end
end

if ARGV.empty?
  fix_all_entries
else
  fix_selected(ARGV)
end
