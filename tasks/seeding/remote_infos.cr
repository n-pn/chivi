require "file_utils"
require "option_parser"

require "../../src/_seeds/rm_info"
require "./_info_seeding.cr"

class Chivi::SeedRemoteInfo
  getter name : String

  def initialize(@name)
    @seeding = InfoSeeding.new(@name)
  end

  def init!(upto = 1, skip_missing = false)
    skip_missing = true if @name == "jx_la"

    1.upto(upto) do |idx|
      sbid = idx.to_s

      unless access = access_time(sbid)
        next if skip_missing
        access = Time.utc.to_unix
      end

      next if @seeding.access.get_value(sbid).try(&.to_i64.> access)
      @seeding.access.upsert(sbid, access.to_s)

      parser = RmInfo.init(@name, sbid, expiry: Time.utc - 1.years)

      if @seeding._index.upsert(sbid, "#{parser.btitle}  #{parser.author}")
        @seeding.set_intro(sbid, parser.intro)
        @seeding.genres.upsert(sbid, parser.bgenre)
        @seeding.covers.upsert(sbid, parser.cover)
      end

      @seeding.status.upsert(sbid, parser.status.to_s)
      @seeding.update.upsert(sbid, parser.update.to_s)
    rescue err
      puts err.colorize.red
    end

    @seeding.save!
  end

  def access_time(sbid : String) : Int64?
    file = RmInfo.path_for(@name, sbid)
    File.info?(file).try(&.modification_time.to_unix)
  end
end

remote_file = File.join({{ __DIR__ }}, "consts/remotes.json")
remote_data = Hash(String, Int32).from_json(File.read(remote_file)).reject

skip_missing = ARGV.includes?("!skip")

selected = (ARGV.empty? ? remote_data.keys : ARGV).reject(&.starts_with?("!"))
puts "- SEEDS: #{selected}".colorize.blue

remote_data.each do |seed, upto|
  next unless selected.includes?(seed)

  worker = Chivi::SeedRemoteInfo.new(seed)
  worker.init!(upto, skip_missing)
end
