require "./../shared/seed_data"

module CV
  def fix_all_entries
    books = Nvinfo.query.order_by(id: :desc).to_a

    books.each_with_index(1) do |nvinfo, index|
      next if nvinfo.id <= 0
      nvinfo.fix_names!

      if index % 100 == 0
        puts "- [fix_bnames] <#{index}/#{books.size}>".colorize.blue
      end
    end
  end

  def fix_selected(titles : Array(String))
    titles.each do |title|
      query = Nvinfo.query.filter_btitle(title)
      query.each(&.fix_names!)
    end
  end

  if ARGV.empty?
    fix_all_entries
  else
    fix_selected(ARGV)
  end
end
