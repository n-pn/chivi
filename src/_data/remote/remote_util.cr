require "colorize"
require "compress/gzip"

require "../../_util/site_link"

module CV::RemoteUtil
  extend self

  def fetch(file : String, link : String, ttl = 1.week, lbl = "-/-")
    unless File.info?(file).try(&.modification_time.> Time.utc - ttl)
      loops = 0

      while loops < 3
        puts " - #{lbl} Fetching #{link} (loop: #{loops})".colorize.cyan
        `curl -L -k -s -f -m 30 '#{link}' | gzip > #{file}`
        break if $?.success?
        sleep loops * 100
      end
    end

    File.open(file) { |io| Compress::Gzip::Reader.open(io, &.gets_to_end) }
  end

  def fetch_all(input : Array(Tuple(String, String)), sname : String)
    workers = ideal_workers_count_for(sname)
    channel = Channel(Nil).new(workers)

    input.each_with_index(1) do |(file, link), idx|
      channel.receive if idx > workers

      spawn do
        fetch(file, link, ttl: 30.minutes)
        sleep ideal_delayed_time_for(sname)
      rescue err
        puts err.inspect_with_backtrace
      ensure
        channel.send(nil)
      end
    end

    workers.times { channel.receive }
  end

  def ideal_workers_count_for(sname : String) : Int32
    case sname
    when "zhwenpg", "shubaow"  then 1
    when "paoshu8", "biqu5200" then 2
    when "duokan8", "69shu"    then 4
    else                            6
    end
  end

  def ideal_delayed_time_for(sname : String)
    case sname
    when "shubaow"
      Random.rand(1000..2000).milliseconds
    when "zhwenpg"
      Random.rand(500..1000).milliseconds
    when "biqu5200"
      Random.rand(200..500).milliseconds
    else
      10.milliseconds
    end
  end
end
