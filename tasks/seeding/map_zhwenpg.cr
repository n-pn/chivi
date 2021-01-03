require "./_info_seed.cr"

class CV::ZhwenpgParser
  def initialize(@node : Myhtml::Node, @status : Int32)
  end

  getter rows : Array(Myhtml::Node) { @node.css("tr").to_a }
  getter link : Myhtml::Node { rows[0].css("a").first }
  getter sbid : String { link.attributes["href"].sub("b.php?id=", "") }

  getter author : String { rows[1].css(".fontwt").first.inner_text.strip }
  getter btitle : String { link.inner_text.strip }
  getter bgenre : String { rows[2].css(".fontgt").first.inner_text }

  getter intro : Array(String) { extract_intro || [] of String }
  getter cover : String { @node.css("img").first.attributes["data-src"] }

  getter mftime : String { rows[3].css(".fontime").first.inner_text }
  getter update : Time { TimeUtils.parse_time(mftime) }

  def extract_intro
    return unless node = rows[4]?
    TextUtils.split_html(node.inner_text("\n"))
  end
end

class CV::SeedInfoZhwenpg
  getter check = Hash(String, Int32).new
  getter input = InfoSeed.new("zhwenpg")

  def expiry(page : Int32 = 1)
    Time.utc - 8.hours * page
  end

  def page_url(page : Int32, status = 0)
    if status > 0
      "https://novel.zhwenpg.com/index.php?page=#{page}&genre=1"
    else
      "https://novel.zhwenpg.com/index.php?page=#{page}&order=1"
    end
  end

  def page_path(page : Int32, status = 0)
    "_db/.cache/zhwenpg/pages/#{"#{page}-#{status}.html"}"
  end

  def update!(page = 1, status = 0)
    puts "\n[-- Page: #{page} --]".colorize.light_cyan.bold

    file = page_path(page, status)

    unless html = FileUtils.read(file, expiry: expiry(page))
      url = page_url(page, status)
      html = HttpUtils.get_html(url, encoding: "UTF-8")
      File.write(file, html)
    end

    doc = Myhtml::Parser.new(html)
    nodes = doc.css(".cbooksingle").to_a[2..-2]
    nodes.each_with_index do |node, idx|
      update_info!(node, status, label: "#{idx + 1}/#{nodes.size}")
    end

    @input.save!(mode: :upds)
  end

  def update_info!(node, status, label = "1/1") : Void
    parser = ZhwenpgParser.new(node, status)
    sbid = parser.sbid

    return if @check.has_key?(sbid)
    @check[sbid] = status

    btitle, author = parser.btitle, parser.author

    if @input._index.add(sbid, [btitle, author])
      @input.set_intro(sbid, parser.intro)
      @input.bgenre.add(sbid, parser.bgenre)
      @input.bcover.add(sbid, parser.cover)
    end

    @input.status.add(sbid, status)
    @input.access_tz.add(sbid, Time.utc.to_unix)

    update_at = parser.update + 12.hours
    update_at = Time.utc if update_at > Time.utc

    @input.update_tz.add(sbid, update_at.to_unix)

    puts "\n<#{label}> {#{sbid}} [#{btitle}  #{author}]"
  rescue err
    puts "ERROR: #{err}".colorize.red
  end

  def upsert_all!
    @check.each_with_index do |(sbid, status), idx|
      zh_slug, existed = @input.upsert!(sbid)

      unless existed
        btitle, author = @input._index.get(sbid).not_nil!
        voters, rating = fake_rating(btitle, author)
        Nvinfo.set_score(zh_slug, voters, rating)
      end

      hv_slug = Nvinfo._index.fval(zh_slug)
      colored = existed ? :yellow : (status ? :green : :blue)

      puts "- <#{idx + 1}/#{@check.size}> [#{hv_slug}] saved!".colorize(colored)
      Nvinfo.save!(mode: :upds) if idx % 10 == 9
    end

    Nvinfo.save!(mode: :full)
  end

  RATING_TEXT = File.read("tasks/seeding/consts/ratings.json")
  RATING_DATA = Hash(String, Tuple(Int32, Float32)).from_json RATING_TEXT

  def fake_rating(btitle : String, author : String)
    voters, rating = RATING_DATA["#{btitle}--#{author}"]? || {0, 0_f32}
    {voters, (rating * 10).round.to_i}
  end
end

worker = CV::SeedInfoZhwenpg.new
FileUtils.mkdir_p("_db/.cache/zhwenpg/pages")

puts "\n[-- Load indexes --]".colorize.cyan.bold

1.upto(3) { |page| worker.update!(page, status: 1) }
1.upto(10) { |page| worker.update!(page, status: 0) }
worker.input.save!(mode: :full)

worker.upsert_all!
