require "../../src/ysapp/data/yscrit_form"
require "../../src/ysapp/data/ysuser_form"

DIR   = "var/ysraw/crits-by-book"
WHOLE = ARGV.includes?("--whole")

Log.setup_from_env

dirs = Dir.children(DIR)
dirs.each_with_index(1) do |yb_id, idx|
  files = Dir.glob("#{DIR}/#{yb_id}/*.zst")

  files.select!(&.ends_with?("latest.json.zst")) unless WHOLE
  next if files.empty?

  files.sort_by! { |x| File.basename(x).split('.', 2).first.to_i? || 0 }
  total = files.size

  files.each_with_index(1) do |path, jdx|
    puts "- [#{idx}/#{dirs.size}] <#{jdx}/#{total}>: #{path}"
    seed_crit_by_book(path, yb_id.to_i)
  rescue ex
    Log.error(exception: ex) { path }
  end
end

def seed_crit_by_book(path : String, yb_id : Int32)
  json = read_zstd(path)
  return unless json.includes?("data")

  data = YS::RawBookComments.from_json(json)
  crits = data.comments
  return if crits.empty?

  YS::YsuserForm.bulk_upsert!(crits.map(&.user))

  # rtime = File.info(path).modification_time.to_unix
  # YS::YscritForm.bulk_upsert!(crits, rtime)

  # PG_DB.exec <<-SQL, data.total, yb_id
  #   update ysbooks set crit_total = $1
  #   where id = $2 and crit_total < $1
  #   SQL

  puts "ybook: #{yb_id}, crits: #{crits.size}".colorize.yellow
end
