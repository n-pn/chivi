require "./../shared/seed_data"

module CV::FixBnames
  extend self

  DIR = "var/nvinfos/fixed"
  class_getter vtitles : TsvStore { TsvStore.new("#{DIR}/btitles_vi.tsv") }

  def fix_all!
    books = Nvinfo.query.order_by(id: :desc).to_a

    books.each_with_index(1) do |nvinfo, index|
      nvinfo.fix_names!
      puts "- [fix_bnames] <#{index}/#{books.size}>".colorize.blue if index % 100 == 0
    end
  end

  def fix_any!(titles : Array(String))
    titles.each do |title|
      query = Nvinfo.query.filter_btitle(title)
      query.each(&.fix_names!)
    end
  end
end

if ARGV.empty?
  CV::FixBnames.fix_all!
else
  CV::FixBnames.fix_any!(ARGV)
end
