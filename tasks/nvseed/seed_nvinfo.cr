require "./nvinfo_data"

class CV::SeedNvinfo
  DIR = "var/nvinfos"

  class_getter authors : Hash(String, Author) do
    query = Author.query.select("id", "zname")

    query.each_with_object({} of String => Author) do |author, output|
      output[author.zname] = author
    end
  end

  def self.get_author(zname : String)
    authors[zname] ||= Author.find({zname: zname}) || begin
      return unless yield
      Author.upsert!(zname)
    end
  end

  def self.get_author(zname : String)
    get_author(zname) { false }
  end

  def self.get_author!(zname : String) : Author
    authors[zname] ||= Author.upsert!(zname)
  end

  ###########

  def initialize(@sname)
    @dir = File.join(DIR, @sname)
  end

  def seed_all
    print_stats

    Dir.each_child(@dir) do |slice|
      seed_slice(slice)
      print_stats
    end
  end

  def print_stats
    puts "- [seed #{@sname}] <#{idx.colorize.cyan}>, \
            authors: #{authors.size.colorize.cyan}, \
            nvinfos: #{Nvinfo.query.count.colorize.cyan}, \
            nvseeds: #{Nvseed.query.count.colorize.cyan}"
  end

  def seed_slice(slice : Int32 | String)
    sdata = NvinfoData.new(@sname, slice)
    sdata._index.each do |snvid, bindex|
      next unless should_seed?(snvid, bindex)
    end
  end
end
