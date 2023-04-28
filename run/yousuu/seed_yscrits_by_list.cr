require "../../src/ysapp/data/yscrit_form"

DIR   = "var/ysraw/crits-by-list"
WHOLE = ARGV.includes?("--whole")
BRIEF = ARGV.includes?("--brief")

# struct PQ::Param

# end

counter = 0

dirs = Dir.children(DIR)
dirs.each_with_index(1) do |yl_id, idx|
  files = Dir.glob("#{DIR}/#{yl_id}/*.zst")

  files.select!(&.ends_with?("latest.json.zst")) unless WHOLE
  next if files.empty?

  files.sort_by! { |x| File.basename(x).split('.', 2).first.to_i? || 0 }
  total = files.size

  yl_id = yl_id.hexbytes

  PG_DB.exec "begin"

  files.each_with_index(1) do |path, jdx|
    puts "- [#{idx}/#{dirs.size}] <#{jdx}/#{total}> (count: #{counter}) : #{path}"
    counter &+= seed_crit_by_list(path, yl_id: yl_id)
  rescue ex
    Log.error(exception: ex) { path }
  end

  PG_DB.exec "commit"
end

def seed_crit_by_list(path : String, yl_id : Bytes)
  json = read_zstd(path)
  return 0 unless json.includes?("data")

  data = YS::RawListEntries.from_json(json)
  crits = data.books
  return 0 if crits.empty?

  vl_id = YS::DBRepo.get_vl_id(yl_id)

  if BRIEF
    crits.each do |crit|
      YS::YscritForm.update_list_id(crit.yc_id.hexbytes, yl_id, vl_id)
    end
  else
    rtime = File.info(path).modification_time.to_unix
    crit_ids = YS::YscritForm.bulk_upsert!(crits, rtime: rtime).map(&.id!)

    YS::YscritForm.update_list_id(crit_ids, yl_id, vl_id)

    PG_DB.exec <<-SQL, data.total, rtime, yl_id
    update yslists
    set book_total = $1, book_rtime = $2
    where yl_id = $3 and book_total < $1
    SQL

    puts "ylist: #{yl_id.join(&.to_s(16))}, crits: #{crits.size}".colorize.yellow
  end

  crits.size
end
