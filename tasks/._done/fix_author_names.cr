require "../nvinfo/shared/seed_data.cr"
require "../nvinfo/shared/seed_util.cr"

class CV::FixAuthors
  @seed = SeedData.new("yousuu")

  def fix_authors!
    map_author = Hash(String, Set(String)).new { |h, k| h[k] = Set(String).new }
    map_btitle = Hash(String, Set(String)).new { |h, k| h[k] = Set(String).new }

    fix_author = TsvStore.new("db/nv_fixes/zauthor.tsv")

    @seed._index.data.each do |snvid, value|
      voters = @seed.rating.ival(snvid)
      next if voters = 0

      _, title, author = value
      map_btitle[author] << title
      map_author[sanitize_author(author)] << author
    end

    map_author.each do |fixed, authors|
      authors = authors.reject do |a|
        a =~ /^ |(\.QD)|(\.CS)|\)|）|\s$/ || a.includes?("最新更新") || fix_author.has_key?(a)
      end

      next if authors.empty?

      if authors.size > 1
        # puts "- [#{fixed}] <== #{authors.to_a}".colorize.red
        # print "(1: keep 1, 2: keep 2, other: skip): "

        # case getch
        # when '1' then fix_author.set!(authors[1], authors[0])
        # when '2' then fix_author.set!(authors[0], authors[1])
        # when 'c' then break
        # end
        # puts
      elsif authors.first != fixed
        puts "- [#{fixed}] <== [#{authors.first}]".colorize.light_red
      end
    end

    fix_author.save!
  end

  def sanitize_author(author : String)
    # author = author.gsub(/^[^\p{Han}\p{Hiragana}\p{Katakana}\p{L}\p{N}_]/, "")
    # author = author.gsub(/[^\p{Han}\p{Hiragana}\p{Katakana}\p{L}\p{N}_.·]$/, "")

    author.strip
  end

  def getch
    STDIN.flush
    STDIN.raw &.read_char
  end
end
