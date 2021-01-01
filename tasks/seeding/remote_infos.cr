require "file_utils"
require "option_parser"

require "../../src/filedb/nvinit/rm_info"
require "./_info_seeding.cr"

class CV::SeedRemoteInfo
  getter seed : String

  def initialize(@seed)
    @input = InfoSeeding.new(@seed)
  end

  def init!(upto = 1, skip_missing = false)
    skip_missing = true if @seed == "jx_la"

    1.upto(upto) do |idx|
      sbid = idx.to_s

      unless access_tz = access_time(sbid)
        next if skip_missing
        access_tz = Time.utc.to_unix
      end

      next if @input.access_tz.fval(sbid).try(&.to_i64.> access_tz)
      @input.access_tz.add(sbid, access_tz)

      parser = RmInfo.init(@seed, sbid, expiry: Time.utc - 1.years)
      btitle, author = parser.btitle, parser.author
      next if btitle.empty? || author.empty?

      if @input._index.add(sbid, [btitle, author])
        @input.set_intro(sbid, parser.bintro)
        @input.bgenre.add(sbid, parser.bgenre)
        @input.bcover.add(sbid, parser.bcover)
      end

      @input.status.add(sbid, parser.status_int)
      @input.update_tz.add(sbid, parser.updated_at)
    rescue err
      puts err.colorize.red
    end

    @input.save!
  end

  def access_time(sbid : String) : Int64?
    file = RmInfo.path_for(@seed, sbid)
    File.info?(file).try(&.modification_time.to_unix)
  end
end

remote_file = File.join({{ __DIR__ }}, "consts/remotes.json")
remote_data = Hash(String, Int32).from_json(File.read(remote_file))

skip_missing = ARGV.includes?("!skip")

selected = (ARGV.empty? ? remote_data.keys : ARGV).reject(&.starts_with?("!"))
puts "- SEEDS: #{selected}".colorize.blue

remote_data.each do |seed, upto|
  next unless selected.includes?(seed)

  worker = CV::SeedRemoteInfo.new(seed)
  worker.init!(upto, skip_missing)
end
