# require "db"
# require "pg"
# require "../../src/cv_env"

# def open_db(&)
#   DB.open(CV_ENV.database_url) { |db| yield db }
# end

# INP = "var/chaps/seeds"

# def reject_unused(sname : String)
#   Dir.mkdir_p("var/chaps/seeds.rem/#{sname}")

#   used_ids = open_db do |db|
#     db.query_all <<-SQL, args: [sname], as: Int32
#       select s_bid from wnseeds where sname = $1
#     SQL
#   end

#   existing = Dir.children("#{INP}/#{sname}").map { |x| File.basename(x, ".db").to_i }
#   unused = existing - used_ids

#   puts "#{sname}: #{used_ids.size}, existing: #{existing.size}, unused: #{unused.size}"
#   File.write("var/chaps/#{sname}.missing-db.txt", (used_ids - existing).join('\n'))

#   unused.each do |b_id|
#     inp_path = File.join(INP, sname, "#{b_id}.db")
#     out_path = inp_path.sub("seeds", "seeds.rem")
#     File.rename inp_path, out_path
#   end
# end

# snames = Dir.children(INP)

# snames.each do |sname|
#   next if sname.in?("miscs", "zxcs_me", "hetushu")
#   reject_unused(sname)
# end
