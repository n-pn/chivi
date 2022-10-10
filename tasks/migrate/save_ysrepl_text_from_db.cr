require "../../src/ysapp/models/*"
require "compress/zip"

def saved_crit_list(ysbook_id : Int64)
  zip_file = "var/ys_db/crits/#{ysbook_id}-zh.zip"
  return [] of String unless File.exists?(zip_file)

  Compress::Zip::File.open(zip_file) do |zip|
    zip.entries.map { |x| File.basename(x.filename, ".txt") }
  end
end

CV::Ysbook.query.each do |ysbook|
  saved_crits = saved_crit_list(ysbook.id)

  query = YS::Yscrit.query.where("ysbook_id = ?", ysbook.id)
  query.where("ztext <> '$$$'")

  unless saved_crits.empty?
    literal = saved_crits.map { |x| "'#{x}'" }.join(", ")
    query.where("origin_id not in (#{literal})", saved_crits)
  end

  query.select("id", "origin_id", "ztext")

  crits = query.to_a.reject!(&.ztext.empty?)
  next if crits.empty?

  puts "<#{ysbook.id}> unsaved crits: #{crits.size}"

  save_dir = "var/ys_db/crits/#{ysbook.id}-zh"
  Dir.mkdir_p(save_dir)

  crits.each do |crit|
    text_path = "#{save_dir}/#{crit.origin_id}.txt"
    File.write(text_path, crit.ztext)
  end

  zip_file = save_dir + ".zip"
  `zip --include=\\*.txt -rjmq "#{zip_file}" "#{save_dir}"`
  Dir.delete(save_dir)
end
