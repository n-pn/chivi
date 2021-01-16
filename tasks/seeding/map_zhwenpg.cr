require "./_info_seed.cr"

class CV::Seeds::ZhwenpgParser
  def initialize(@node : Myhtml::Node)
  end

  getter rows : Array(Myhtml::Node) { @node.css("tr").to_a }
  getter link : Myhtml::Node { rows[0].css("a").first }
  getter sbid : String { link.attributes["href"].sub("b.php?id=", "") }

  getter author : String { rows[1].css(".fontwt").first.inner_text.strip }
  getter btitle : String { link.inner_text.strip }
  getter bgenre : String { rows[2].css(".fontgt").first.inner_text }

  getter intro : Array(String) { extract_intro }
  getter cover : String { @node.css("img").first.attributes["data-src"] }

  getter mftime : String { rows[3].css(".fontime").first.inner_text }
  getter update : Time { TimeUtils.parse_time(mftime) }

  def extract_intro
    return [] of String unless node = rows[4]?
    TextUtils.split_html(node.inner_text("\n"))
  end
end

class CV::Seeds::MapZhwenpg
  def initialize
    @seeding = InfoSeed.new("zhwenpg")
    @checked = Set(String).new
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
    nodes.each_with_index do |node, idx|
      update!(node, status, label: "#{idx + 1}/#{nodes.size}")
    end

    save!(mode: :upds)
  end

  def save!(mode : Symbol = :full)
    @seeding.save!(mode: mode)
  end

  def update!(node, status, label = "1/1") : Void
    parser = ZhwenpgParser.new(node)
    sbid = parser.sbid

    return if @checked.includes?(sbid)
    @checked.add(sbid)

    btitle, author = parser.btitle, parser.author

    if @seeding._index.add(sbid, [btitle, author])
      @seeding.set_intro(sbid, parser.intro)
      @seeding.bgenre.add(sbid, parser.bgenre)
      @seeding.bcover.add(sbid, parser.cover)
    end

    @seeding.status.add(sbid, status)
    @seeding.access_tz.add(sbid, Time.utc.to_unix)

    update_at = parser.update + 12.hours
    update_at = Time.utc if update_at > Time.utc

    @seeding.update_tz.add(sbid, update_at.to_unix)

    puts "\n<#{label}> {#{sbid}} [#{btitle}  #{author}]"
  rescue err
    puts "ERROR: #{err}".colorize.red
  end

  def seed!
    @checked.each_with_index do |sbid, idx|
      bhash, existed = @seeding.upsert!(sbid)
      fake_rating!(bhash, sbid) if NvFields.rating.ival(bhash) == 0

      bslug = NvFields._index.fval(bhash)
      colored = existed ? :yellow : :green

      puts "- <#{idx + 1}/#{@checked.size}> [#{bslug}] saved!".colorize(colored)
      if idx % 10 == 9
        Nvinfo.save!(mode: :upds)
        @seeding.chseed.save!(mode: :upds)
      end
    end

    Nvinfo.save!(mode: :full)
    @seeding.chseed.save!(mode: :full)
  end

  FAKE_RATING = ValueMap.new("tasks/seeding/fake_ratings.tsv", mode: 2)

  def fake_rating!(bhash : String, sbid : String)
    btitle, author = @seeding._index.get(sbid).not_nil!
    return unless vals = FAKE_RATING.get("#{btitle}  #{author}")

    voters, rating = vals[0].to_i, vals[1].to_i
    pp [voters, rating]

    NvFields.set_score(bhash, voters, rating)
  end
end

worker = CV::Seeds::MapZhwenpg.new
FileUtils.mkdir_p("_db/.cache/zhwenpg/pages")

puts "\n[-- Load indexes --]".colorize.cyan.bold

1.upto(3) { |page| worker.init!(page, status: 1) }
1.upto(10) { |page| worker.init!(page, status: 0) }

worker.save!(mode: :full)
worker.seed!
