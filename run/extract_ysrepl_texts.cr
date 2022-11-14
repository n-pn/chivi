# require "db"
# require "pg"
# require "amber"

# PGDB = DB.open(Amber.settings.database_url)
# at_exit { PGDB.close }

# record Crit, id : Int64, origin_id : String do
#   include DB::Serializable
# end

# crits = PGDB.query_all "select id, origin_id from yscrits where repl_count > 0 ", as: Crit
# puts "total reviews: #{crits.size}"

# record Data, origin_id : String, ztext : String, vhtml : String do
#   include DB::Serializable
# end

# def export_data(crit)
#   group = crit.origin_id[0..2]

#   ztext_dir = "var/ysapp/repls.tmp/#{group}-zh/#{crit.origin_id}"
#   vhtml_dir = "var/ysapp/repls.tmp/#{group}-vi/#{crit.origin_id}"

#   Dir.mkdir_p(ztext_dir)
#   Dir.mkdir_p(vhtml_dir)

#   query = "select origin_id, ztext, vhtml from ysrepls where yscrit_id = $1"

#   PGDB.query_each(query, args: [crit.id]) do |rs|
#     origin_id, ztext, vhtml = rs.read(String, String, String)

#     File.write("#{ztext_dir}/#{origin_id}.txt", ztext)
#     File.write("#{vhtml_dir}/#{origin_id}.htm", vhtml)
#   end
# end

# tracker_log = "tmp/export-ysrepl.log"
# tracker = File.read_lines(tracker_log).reject!(&.empty?).map(&.to_i64).to_set

# crits.each do |crit|
#   next if tracker.includes?(crit.id)
#   puts "- review: #{crit.origin_id}"

#   export_data(crit)
#   tracker << crit.id
#   File.open(tracker_log, "a", &.print("\n#{crit.id}"))
# rescue err
#   puts "#{crit.id}: #{err}"
# end

def zip_folder(inp_dir : String)
  out_dir = inp_dir.sub(".tmp", "")
  Dir.mkdir_p(out_dir)

  Dir.children(inp_dir).each do |folder|
    inp_path = File.join(inp_dir, folder)
    zip_path = File.join(out_dir, "#{folder}.zip")

    # puts [inp_path, zip_path]
    `zip -FS -jrq "#{zip_path}" #{inp_path}`
  end
end

inputs = Dir.glob("var/ysapp/repls.tmp/*")
waiter = Channel(Nil).new(6)

inputs.each_with_index(1) do |input, i|
  waiter.receive if i > 6

  spawn do
    puts input
    zip_folder(input)
  ensure
    waiter.send(nil)
  end
end

6.times { waiter.receive }
