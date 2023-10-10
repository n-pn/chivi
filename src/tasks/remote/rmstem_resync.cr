require "colorize"
require "option_parser"

ENV["CV_ENV"] ||= "production"
require "../../rdapp/data/rmstem"

# crawl book pages from remote sources

class RmstemResync
  @host : Rmhost

  def initialize(@sname : String, @conns = 6, @stale = Time.utc - 10.days)
    @host = Rmhost.from_name!(sname)
    Dir.mkdir_p "var/.keep/rmbook/#{@host.savepath}"
  end

  def get_max_bid
    @host.get_max_bid(6.hours)
  end

  def sync_one(sn_id : String | Int32, force = false)
    book_file = @host.book_file(sn_id)
    book_href = @host.book_href(sn_id)

    bhtml = @host.load_page(book_href, book_file, stale: @stale)

    entry = RD::Rmstem.from_html(bhtml, @sname, sn_id.to_s, force: force)
    entry.try(&.rtime = File.info(book_file).modification_time.to_unix)

    entry ? entry.upsert! && true : false
  rescue ex
    if ex.message.try(&.ends_with?("404"))
      query = "update rmstems set _flag = 404 where sname = $1 and sn_id = $2"
      PGDB.exec query, @sname, sn_id.to_s
    end

    false
  end

  RM_SQL = "select sn_id::int from rmstems where sname = $1 and _flag = -404"

  def sync_all(lower : Int32, upper : Int32, force = false)
    puts "Syncing [#{@sname}] from #{lower} to #{upper}!".colorize.yellow

    skips = PGDB.query_all(RM_SQL, @sname, as: Int32).to_set

    input = (lower..upper).to_a.reject!(&.in?(skips))
    total = input.size

    inp_ch = Channel({Int32, Int32}).new(total)
    out_ch = Channel(String).new(@conns)

    @conns.times do
      spawn do
        loop do
          sn_id, index = inp_ch.receive
          color = sync_one(sn_id: sn_id, force: force) ? :green : :red

          out_ch.send("- <#{index}/#{total}> [#{@sname}] #{sn_id.colorize(color)} done.")
        rescue err
          out_ch.send("- <#{index}/#{total}>: error syncing [#{sn_id}]: #{err}")
        end
      end
    end

    input.each_with_index(1) { |input, index| inp_ch.send({input, index}) }
    total.times { puts out_ch.receive }
  end
end

sname = "!69shuba.com"
conns = 3

lower = 1
upper = 10

tspan = 30.days
force = false

OptionParser.parse(ARGV) do |parser|
  parser.on("-s SNAME", "source name") { |s| sname = s }
  parser.on("-c CONNS", "total connection") { |i| conns = i.to_i }
  parser.on("-r", "force reseed") { force = true }

  parser.on("-l LOWER_ID", "min book id") { |i| lower = i.to_i }
  parser.on("-u UPPER_ID", "max book id") { |i| upper = i.to_i }
  parser.on("--ttl TSPAN", "time to live") { |i| tspan = i.to_i.days }
end

worker = RmstemResync.new(sname, conns, stale: Time.utc - tspan)
upper = worker.get_max_bid if upper < lower
worker.sync_all(lower: lower, upper: upper, force: force)
