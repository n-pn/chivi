require "./../shared/bootstrap"

CV::VpDict.regular.set("三国", ["Tam Quốc"], "nn")

def fix_all_entries
  books = CV::Nvinfo.query.order_by(id: :desc).to_a

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
    query = CV::Nvinfo.query.filter_btitle(title)
    query.each do |nvinfo|
      nvinfo.fix_names!
      nvinfo.author.tap(&.set_vname).save!
    end
  end
end

if ARGV.empty?
  fix_all_entries
else
  fix_selected(ARGV)
end
