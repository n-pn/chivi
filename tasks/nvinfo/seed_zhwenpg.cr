require "../shared/seed_util.cr"

class CV::ZhwenpgParser
  def initialize(@node : Myhtml::Node)
  end

  getter rows : Array(Myhtml::Node) { @node.css("tr").to_a }
  getter link : Myhtml::Node { rows[0].css("a").first }

  getter snvid : String { link.attributes["href"].sub("b.php?id=", "") }

  getter author : String { rows[1].css(".fontwt").first.inner_text.strip }
  getter ztitle : String { link.inner_text.strip }

  getter bcover : String { @node.css("img").first.attributes["data-src"] }
  getter bgenre : String { rows[2].css(".fontgt").first.inner_text }

  getter bintro : Array(String) do
    TextUtils.split_html(rows[4]?.try(&.inner_text("\n")) || "")
  end

  getter mftime : Int64 do
    update_str = rows[3].css(".fontime").first.inner_text
    updated_at = TimeUtils.parse_time(update_str) + 24.hours

    updated_at = Time.utc if updated_at > Time.utc
    updated_at.to_unix
  end
end

class CV::SeedZhwenpg
  ::FileUtils.mkdir_p("_db/.cache/zhwenpg/pages")

  @checked = Set(String).new

  def seed!(page = 1, status = 0)
    puts "\n[-- Page: #{page} (status: #{status}) --]".colorize.light_cyan.bold

    file = page_path(page, status)
    link = page_link(page, status)

    html = HttpUtils.load_html(link, file, ttl: 4.hours * page, label: page.to_s)
    atime = SeedUtil.get_mtime(file) || Time.utc.to_unix

    pdoc = Myhtml::Parser.new(html)
    nodes = pdoc.css(".cbooksingle").to_a[2..-2]

    nodes.each_with_index(1) do |node, idx|
      parser = ZhwenpgParser.new(node)

      snvid = parser.snvid
      next if @checked.includes?(snvid)

      puts "\n<#{idx}/#{nodes.size}}> [#{parser.ztitle}] (#{snvid})"
      @checked.add(snvid)

      zhbook = save_zhbook(parser, status, atime)
      save_btitle(zhbook)
    rescue err
      puts "ERROR: #{err}".colorize.red
    end
  end

  def save_zhbook(parser : ZhwenpgParser, status = 0, bumped = Time.utc) : Zhbook
    output = begin
      zseed = Zhseed.index("zhwenpg")
      znvid = CoreUtils.decode32_zh(parser.snvid).to_i

      Zhbook.get!(zseed, znvid)
    end

    output.cvbook_id ||= 0

    output.author = parser.author
    output.ztitle = parser.ztitle

    output.genres = [parser.bgenre]
    output.bcover = parser.bcover
    output.bintro = parser.bintro.join("\n")

    output.status = status
    output.bumped = bumped
    output.mftime = parser.mftime

    output.tap(&.save!)
  end

  def save_btitle(zhbook : Zhbook)
    author = begin
      zname = BookUtils.fix_zh_author(zhbook.author, zhbook.ztitle)
      Author.upsert!(zname)
    end

    cvbook = begin
      ztitle = BookUtils.fix_zh_author(zhbook.ztitle, author.zname)
      Cvbook.upsert!(author, ztitle)
    end

    zhbook.update!(cvbook_id: cvbook.id)

    cvbook.add_zhseed(zhbook.zseed)
    cvbook.set_genres(zhbook.genres)

    cvbook.set_bcover("zhwenpg-#{zhbook.snvid}.webp")
    cvbook.set_zintro(zhbook.bintro)

    cvbook.set_shield(1) if cvbook.bgenres.includes?("Phi sắc")
    cvbook.set_status(zhbook.status)

    cvbook.set_mftime(zhbook.mftime)

    if cvbook.voters == 0
      voters, rating = get_scores(cvbook.ztitle, author.zname)
      cvbook.set_scores(voters, rating)
    end

    if zhbook.chap_count == 0
      ttl = Time.utc - Time.unix(zhbook.mftime)
      chinfo = ChInfo.new(cvbook.bhash, "zhwenpg", zhbook.snvid)
      _, zhbook.chap_count, zhbook.last_zchid = chinfo.update!(mode: 1, ttl: ttl)
      zhbook.save!
    end

    cvbook.save!
  end

  private def get_scores(ztitle : String, author : String)
    if score = SeedUtil.rating_fix.get("#{ztitle}  #{author}")
      score.map(&.to_i)
    else
      [Random.rand(25..50), Random.rand(40..50)]
    end
  end

  def page_link(page : Int32, status = 0)
    filter = status > 0 ? "genre" : "order"
    "https://novel.zhwenpg.com/index.php?page=#{page}&#{filter}=1"
  end

  def page_path(page : Int32, status = 0)
    "_db/.cache/zhwenpg/pages/#{page}-#{status}.html"
  end
end

seeder = CV::SeedZhwenpg.new
1.upto(3) { |page| seeder.seed!(page, status: 1) }
1.upto(11) { |page| seeder.seed!(page, status: 0) }
