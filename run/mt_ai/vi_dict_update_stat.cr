require "../../src/mt_ai/data/vi_dict"
ENV["MT_DIR"] ||= "var/mt_db"

require "../../src/mt_ai/data/vi_term"

update_query = <<-SQL
  update dicts set total = $1, mtime = $2, users = $3
  where dname = $4
SQL

dnames = MT::ViDict.db.open_ro do |db|
  db.query_all "select dname from dicts", as: String
end

dnames.each_slice(1000) do |group|
  MT::ViDict.db.open_tx do |db|
    group.each do |dname|
      db_path = MT::ViTerm.db_path(dname)
      next unless File.file?(db_path)

      stats = DB.open("sqlite3:#{db_path}?immutable=1") do |db2|
        total = db2.query_one("select count(*) from terms", as: Int32)
        mtime = db2.query_one("select coalesce(max(mtime), 0) from terms", as: Int32)
        users = db2.query_all("select distinct(uname) from terms", as: String)

        {total, mtime, users.join(',')}
      end

      db.exec(update_query, *stats, dname)
    rescue ex
      puts db_path, ex.message
    end
  end
end
