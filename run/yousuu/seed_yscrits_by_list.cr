require "../../src/ysapp/data/yscrit_form"

DIR   = "var/ysraw/crits-by-list"
WHOLE = ARGV.includes?("--whole")

dirs = Dir.children(DIR)
dirs.each_with_index(1) do |yl_id, idx|
  files = Dir.glob("#{DIR}/#{yl_id}/*.zst")

  files.select!(&.ends_with?("latest.json.zst")) unless WHOLE
  next if files.empty?

  files.sort_by! { |x| File.basename(x).split('.', 2).first.to_i? || 0 }
  total = files.size

  yl_id = yl_id.hexbytes

  files.each_with_index(1) do |path, jdx|
    puts "- [#{idx}/#{dirs.size}] <#{jdx}/#{total}> : #{path}"
    seed_crit_by_list(path, yl_id: yl_id)
  rescue ex
    Log.error(exception: ex) { path }
  end
end

def seed_crit_by_list(path : String, yl_id : Bytes)
  json = read_zstd(path)
  return unless json.includes?("data")

  data = YS::RawListEntries.from_json(json)
  crits = data.books

  rtime = File.info(path).modification_time.to_unix
  YS::YscritForm.bulk_upsert(crits, rtime, yl_id)

  PG_DB.exec <<-SQL, data.total, rtime, yl_id
    update yslists
    set book_total = $1, book_rtime = $2
    where yl_id = $3 and book_total < $1
    SQL

  puts "ylist: #{yl_id.join(&.to_s(16))}, crits: #{crits.size}".colorize.yellow
end
