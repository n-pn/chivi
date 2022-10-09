require "sqlite3"
require "../src/ysapp/models/*"

DB.open "sqlite3://./var/ys_db/ysusers.db" do |db|
  db.transaction do |tx|
    YS::Ysuser.query.each_with_cursor(100) do |user|
      add_user(tx.connection, user)
    end
  end
end

def add_user(db, user)
  data = {} of String => DB::Any

  data["id"] = user.origin_id
  data["zname"] = user.zname
  data["vname"] = user.vname
  data["uslug"] = user.vslug

  data["like_count"] = user.like_count
  data["star_count"] = user.star_count

  data["list_count"] = user.list_count
  data["list_total"] = user.list_total

  data["crit_count"] = user.crit_count
  data["crit_total"] = user.crit_total

  data["created_at"] = user.created_at.to_unix
  data["updated_at"] = user.updated_at.to_unix

  fields = data.keys.join(", ")
  values = data.keys.map { "?" }.join(", ")

  db.exec <<-SQL, args: data.values
    replace into users (#{fields}) values (#{values})
  SQL
end
