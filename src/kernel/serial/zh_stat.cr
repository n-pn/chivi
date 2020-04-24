require "json"

class Serial::ZhStat
  include JSON::Serializable

  property status = 0_i32
  property hidden = 0_i32

  property votes = 0_i32
  property score = 0_f64
  property tally = 0_f64
  property mtime = 0_i64

  property chap_count = 0
  property word_count = 0

  def initialize
  end

  def save(name : String)
    File.write(ZhStat.file_path(name), to_json)
  end

  LOCATION = Time::Location.fixed(3600 * 8)
  FORMATS  = {"%F %T", "%F %R", "%F", "%-m/%-d/%Y %r", "%-m/%-d/%Y %T", "%Y/%-m/%-d %T"}

  def self.parse_time(input : String)
    FORMATS.each do |format|
      return Time.parse(input, format, LOCATION).to_unix_ms
    rescue
      next
    end

    puts "Error parsing <#{input}>: unknown time format!".colorize(:red)
    0_i64
  end

  DIR = "data/txt-out/serials"

  def self.file_path(name : String)
    File.join(DIR, "#{name}.meta.zh.json")
  end

  def self.load!(name : String)
    from_json(File.read(file_path(name)))
  end
end
