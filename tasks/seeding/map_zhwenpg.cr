require "./_seeding.cr"

class CV::Seeds::ZhwenpgParser
  def initialize(@node : Myhtml::Node)
  end

  getter rows : Array(Myhtml::Node) { @node.css("tr").to_a }
  getter link : Myhtml::Node { rows[0].css("a").first }

  getter snvid : String { link.attributes["href"].sub("b.php?id=", "") }
  getter author : String { rows[1].css(".fontwt").first.inner_text.strip }
  getter btitle : String { link.inner_text.strip }

  getter intro : Array(String) { extract_intro }
  getter genre : String { rows[2].css(".fontgt").first.inner_text }
  getter cover : String { @node.css("img").first.attributes["data-src"] }

  getter update_str : String { rows[3].css(".fontime").first.inner_text }
  getter updated_at : Time { TimeUtils.parse_time(update_str) }

  def extract_intro
    return [] of String unless node = rows[4]?
    TextUtils.split_html(node.inner_text("\n"))
  end
end

class CV::Seeds::MapZhwenpg
  def initialize
    @seeding = InfoSeed.new("zhwenpg")
    @checked = Set(String).new

    ::FileUtils.mkdir_p("_db/.cache/zhwenpg/pages")
  end

  def expiry(page : Int32 = 1)
    Time.utc - 4.hours * page
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

  def init!(page = 1, status = 0)
    puts "\n[-- Page: #{page} --]".colorize.light_cyan.bold

    file = page_path(page, status)

    unless html = FileUtils.read(file, expiry: expiry(page))
      url = page_url(page, status)
      html = HttpUtils.get_html(url, encoding: "UTF-8")
      File.write(file, html)
    end

    doc = Myhtml::Parser.new(html)
    nodes = doc.css(".cbooksingle").to_a[2..-2]
    nodes.each_with_index(1) do |node, idx|
      update!(node, status, label: "#{idx}/#{nodes.size}")
    end

    save!(mode: :upds)
  end

  def save!(mode : Symbol = :full)
    @seeding.save!(mode: mode)
  end

  def update!(node, status, label = "1/1") : Void
    parser = ZhwenpgParser.new(node)
    snvid = parser.snvid

    return if @checked.includes?(snvid)
    @checked.add(snvid)

    btitle, author = parser.btitle, parser.author

    if @seeding._index.add(snvid, [btitle, author])
      @seeding.set_intro(snvid, parser.intro)
      @seeding.genres.add(snvid, parser.genre)
      @seeding.bcover.add(snvid, parser.cover)
    end

    @seeding.status.add(snvid, status)
    @seeding._atime.add(snvid, Time.utc.to_unix)

    update_at = parser.updated_at + 24.hours
    update_at = Time.utc if update_at > Time.utc

    @seeding._utime.add(snvid, update_at.to_unix)

    puts "\n<#{label}> {#{snvid}} [#{btitle}  #{author}]"
  rescue err
    puts "ERROR: #{err}".colorize.red
  end

  def seed!
    @checked.each_with_index(1) do |snvid, idx|
      bhash, existed = @seeding.upsert!(snvid)
      fake_rating!(bhash, snvid) if NvValues.voters.ival(bhash) == 0

      bslug = NvValues._index.fval(bhash)
      colored = existed ? :yellow : :green

      puts "- <#{idx}/#{@checked.size}> [#{bslug}] saved!".colorize(colored)
      if idx % 10 == 0
        Nvinfo.save!(mode: :upds)
        @seeding.source.save!(mode: :upds)
      end
    end

    Nvinfo.save!(mode: :full)
    @seeding.source.save!(mode: :full)
  end

  FAKE_RATING = ValueMap.new("tasks/seeding/fake_ratings.tsv", mode: 2)

  def fake_rating!(bhash : String, snvid : String)
    btitle, author = @seeding._index.get(snvid).not_nil!

    if vals = FAKE_RATING.get("#{btitle}  #{author}")
      voters, rating = vals[0].to_i, vals[1].to_i
    else
      voters, rating = Random.rand(10..50), Random.rand(40..60)
    end

    NvValues.set_score(bhash, voters, rating)
  end
end

worker = CV::Seeds::MapZhwenpg.new
puts "\n[-- Load indexes --]".colorize.cyan.bold

1.upto(3) { |page| worker.init!(page, status: 1) }
1.upto(10) { |page| worker.init!(page, status: 0) }

worker.save!(mode: :full)
worker.seed!
