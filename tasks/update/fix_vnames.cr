require "../../src/_data/wnovel/wninfo"

# CV::VpDict.regular.set("三国", ["Tam Quốc"], "Na")

def fix_all_entries
  books = CV::Wninfo.query.order_by(id: :desc).to_a

  books.each_with_index(1) do |nvinfo, index|
    next if nvinfo.id <= 0

    old_bslug = nvinfo.bslug
    nvinfo.fix_names!

    next unless nvinfo.bslug != old_bslug
    puts "- <#{index.colorize.blue}/#{books.size}> #{old_bslug} => #{nvinfo.bslug.colorize.blue}"
  end
end

def fix_selected(titles : Array(String))
  titles.each do |title|
    query = CV::Wninfo.query.filter_btitle(title)
    query.each(&.fix_names!)
  end
end

if ARGV.empty?
  fix_all_entries
else
  fix_selected(ARGV)
end
