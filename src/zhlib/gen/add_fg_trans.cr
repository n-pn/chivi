require "log"
require "sqlite3"
require "colorize"

require "../wnchap/*"
require "../../mt_v1/mt_core"
require "../../_util/text_util"

DNAMES = {} of Int32 => String

File.each_line("var/fixed/dicts.tsv") do |line|
  nv_id, dname = line.split('\t', 2)
  DNAMES[nv_id.to_i] = dname
end

def import_one(sname : String, s_bid : Int32, regen = false)
  inp_path = WN::ChInfo.db_path("#{sname}/#{s_bid}")
  return unless mtime = File.info?(inp_path).try(&.modification_time)

  dname = DNAMES[s_bid]? || "combine"
  `bin/gen_ch_trans -s #{sname} -b #{s_bid} -d #{dname}`
  return unless $?.success?

  out_path = WN::ChTran.db_path("#{sname}/#{s_bid}")
  File.utime(mtime, mtime, out_path)
end

def import_all(sname : String, threads = 6, regen : Bool = false)
  Dir.mkdir_p("var/chaps/infos-fg/#{sname}")
  s_bids = Dir.children("var/chaps/texts/#{sname}").map(&.to_i).sort!

  workers = Channel({Int32, Int32}).new(s_bids.size)
  results = Channel(Nil).new(threads)

  threads.times do
    spawn do
      loop do
        s_bid, idx = workers.receive
        import_one(sname, s_bid, regen: regen)
        puts " - <#{idx}/#{s_bids.size}> [#{sname}/#{s_bid}]"
      rescue err
        puts "#{sname}, #{s_bid}, #{err.message} ".colorize.red
      ensure
        results.send(nil)
      end
    end
  end

  s_bids.each_with_index(1) { |s_bid, idx| workers.send({s_bid, idx}) }
  s_bids.size.times { results.receive }
end

threads = ENV["CRYSTAL_WORKERS"]?.try(&.to_i?) || 6
threads = 6 if threads < 6

regen = ARGV.includes?("--regen")
ARGV.reject!(&.starts_with?('-'))

snames = ARGV.empty? ? Dir.children("var/chaps/texts") : ARGV
puts snames.colorize.yellow

snames.each do |sname|
  next if sname == "=user"
  import_all(sname, threads, regen: regen) if sname[0].in?('@', '=')
end
