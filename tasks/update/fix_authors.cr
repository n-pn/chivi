require "./../shared/bootstrap"

module CV::FixAuthors
  extend self

  def fix_all!
    index = 1
    Author.query.order_by(id: :desc).each do |author|
      author.tap(&.set_vname).save!
      puts "- [fix_authors] <#{index}>".colorize.blue if index % 100 == 0
      index += 1
    end
  end

  def fix_selected(names : Array(String))
    names.each do |name|
      Author.query.where("zname like '%#{name}%'").each do |author|
        author.tap(&.set_vname).save!
      end
    end
  end

  if ARGV.empty?
    fix_all
  else
    fix_selected(ARGV)
  end
end
