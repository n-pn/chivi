require "./../src/_data/wnovel/author"

def fix_all!
  index = 1
  CV::Author.query.order_by(id: :desc).each do |author|
    author.tap(&.set_vname).save!
    puts "- [fix_authors] <#{index}>".colorize.blue if index % 100 == 0
    index += 1
  end
end

def fix_selected(names : Array(String))
  names.each do |name|
    CV::Author.query.where("zname like '%#{name}%'").each do |author|
      author.tap(&.set_vname).save!
    end
  end
end

if ARGV.empty?
  fix_all
else
  fix_selected(ARGV)
end
