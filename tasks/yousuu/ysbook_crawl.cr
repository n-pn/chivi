require "json"
require "option_parser"

require "../shared/ysbook_raw"
require "../shared/http_client"

class CV::CrawlYsbook
  DIR = "_db/yousuu/infos"

  def initialize(regen_proxy = false)
    @http = HttpClient.new(regen_proxy)
  end

  enum Mode
    Head; Tail; Rand
  end

  def crawl!(upto = 260000, mode : Mode = :tail)
    queue = (1..upto).to_a
    case mode
    when .tail? then queue.reverse!
    when .rand? then queue.shuffle!
    end

    loops = 0

    until queue.empty?
      qsize = queue.size
      puts "\n[loop: #{loops}, mode: #{mode}, size: #{qsize}]".colorize.cyan

      fails = [] of Int32

      workers = queue.size
      workers = 10 if workers > 10
      channel = Channel(Int32?).new(workers)

      queue.each_with_index(1) do |snvid, idx|
        return if @http.no_proxy?

        spawn do
          result = crawl_info!(snvid, label: "<#{idx}/#{qsize}> [#{snvid}]")
          channel.send(result)
        end

        channel.receive.try { |x| fails << x } if idx > workers
      end

      workers.times { channel.receive.try { |x| fails << x } }

      break if @http.no_proxy?
      queue = fails
      loops += 1
    end
  end

  enum State
    Absent; Staled; Fresh; Error; Blank
  end

  def crawl_info!(snvid : Int32, label = "-/-") : Int32?
    group = (snvid // 1000).to_s.rjust(3, '0')
    file = "#{DIR}/#{group}/#{snvid}.json"

    state, ydata = map_state(file)

    if state.absent? || state.staled?
      link = "https://api.yousuu.com/api/book/#{snvid}"
      return snvid unless @http.save!(link, file, label)
      ydata = YsbookRaw.parse_file(file) || ydata
    end

    ydata.try(&.seed!)
  rescue err
    Log.error { err.inspect_with_backtrace }
  end

  private def map_state(file : String) : {State, YsbookRaw?}
    return {State::Absent, nil} unless mtime = File.info?(file).try(&.modification_time)
    return {State::Blank, nil} unless ydata = YsbookRaw.parse_file(file)
    {mtime >= Time.utc - map_expiry(ydata) ? State::Fresh : State::Staled, ydata}
  rescue err
    Log.error { err.inspect_with_backtrace }

    {State::Error, nil}
  end

  private def map_expiry(ydata : YsbookRaw)
    span = 3.days
    # try again in 3 6 9 days
    span *= (ydata.status + 1)
    # try again in 6 12 18 days if no voter
    ydata.voters == 0 ? span * 2 : span
  end

  def self.run!(argv = ARGV)
    upper_nsvid = Tabkv(Int32).new("var/_common/upper.tsv")["yousuu"]? || 270000
    regen_proxy = false

    crawl_mode = Mode::Tail

    OptionParser.parse(argv) do |opt|
      opt.on("-h", "Crawl from beginning") { crawl_mode = Mode::Head }
      opt.on("-r", "Crawl infos randomly") { crawl_mode = Mode::Rand }
      opt.on("-x", "Refresh proxies") { regen_proxy = true }
      opt.on("-u", "Newest book id") { |x| upper_nsvid = x.to_i }
    end

    new(regen_proxy).crawl!(upper_nsvid, mode: crawl_mode)
  end

  run!(ARGV)
end
