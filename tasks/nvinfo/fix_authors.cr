require "./../shared/bootstrap"

module CV::FixAuthors
  extend self

  def fix_all!
    total, index = Author.query.count, 1
    query = Author.query.order_by(weight: :desc)

    query.each_with_cursor(20) do |author|
      puts "- [fix_authors] <#{index}/#{total}>".colorize.blue if index % 100 == 0
      author.tap(&.fix_name!).save!
      index += 1
    end
  end
end

CV::FixAuthors.fix_all!
