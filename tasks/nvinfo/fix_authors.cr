require "./../shared/seed_data"

module CV::FixAuthors
  extend self

  DIR = "var/fixtures"
  class_getter authors : TsvStore { TsvStore.new("#{DIR}/vi_authors.tsv") }

  def fix_all!
    total, index = Author.query.count, 1
    query = Author.query.order_by(weight: :desc)

    query.each_with_cursor(20) do |author|
      puts "- [fix_authors] <#{index}/#{total}>".colorize.blue if index % 100 == 0
      fix_author!(author)
      index += 1
    end
  end

  def fix_author!(author : Author)
    zname = author.zname
    author.vname = BookUtils.get_vi_author(zname)
    author.vslug = "-#{BookUtils.scrub_vname(author.vname, "-")}-"
    author.save!
  end
end

CV::FixAuthors.fix_all!
