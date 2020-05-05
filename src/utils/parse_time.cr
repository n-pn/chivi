module Utils
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
end
