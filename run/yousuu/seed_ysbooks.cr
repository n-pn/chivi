require "colorize"
require "../../src/ysapp/data/ysbook"

def sync_file(path : String, force = false)
  puts path

  json = read_zstd(path)
  return unless json.includes?("data")

  data = YS::RawYsbook.from_json(json)
  data.info_rtime = File.info(path).modification_time.to_unix

  return unless model = YS::Ysbook.upsert!(data, force: force)

  color = model.nvinfo_id == 0 ? :light_gray : :yellow
  puts "ysbook: #{model.id}, voters: #{model.voters}, nvinfo: #{model.nvinfo_id}".colorize(color)

  return if model.nvinfo_id == 0
  spawn do
    PG_DB.exec <<-SQL, model.nvinfo_id, model.id
    update yscrits set nvinfo_id = $1 where ysbook_id = $2
    SQL
  end
end

whole = ARGV.includes?("--whole")
force = ARGV.includes?("--force")

files = Dir.glob("var/ysraw/books/**/*.zst")
files.select!(&.ends_with?("latest.json.zst")) unless whole

files.sort_by! { |x| File.basename(x).split('.', 2).first.to_i }

files.each do |path|
  sync_file(path, force: force)
rescue ex
  puts ex.colorize.red
end
