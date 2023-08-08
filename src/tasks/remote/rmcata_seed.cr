require "colorize"
require "option_parser"

require "../../zroot/rmbook"
require "../../zroot/zhcata"

class RmcataSeed
  @conf : Rmconf
  @repo : DB::Database

  def initialize(@sname : String, @conns = 6, @stale = Time.utc - 10.days)
    @conf = Rmconf.load!(sname)
    @repo = ZR::Rmbook.db(sname)
  end

  def get_max_bid
    @conf.get_max_bid(6.hours)
  end

  def sync_one(sn_id : String | Int32, force = false)
    file_path = @conf.book_file_path(sn_id)
    link_path = @conf.make_book_path(sn_id)

    bhtml = @conf.load_page(link_path, file_path, stale: @stale)
    rtime = File.info(file_path).modification_time.to_unix

    loop do
      entry = ZR::Rmbook.from_html(bhtml, @sname, sn_id.to_s, force: force)
      return entry ? entry.upsert!(@repo) && true : false
    rescue ex : SQLite3::Exception
      # puts ex.colorize.red
      sleep 0.5 # do again if database is locked
    rescue ex
      return false
    end
  end

  def sync_all(lower : Int32, upper : Int32, force = false)
    puts "Syncing [#{@sname}] from #{lower} to #{upper}!".colorize.yellow

    Dir.mkdir_p "var/.keep/rmbook/#{@conf.hostname}"

    total = upper - lower + 1

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

    (lower..upper).each_with_index(1) { |input, index| inp_ch.send({input, index}) }
    total.times { puts out_ch.receive }
  end
end

sname = "!hetushu"
conns = 6

lower = 1
upper = 0

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

worker = RmcataSeed.new(sname, conns, stale: Time.utc - tspan)
upper = worker.get_max_bid if upper < lower
worker.sync_all(lower: lower, upper: upper, force: force)
