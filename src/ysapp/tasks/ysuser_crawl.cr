require "./_crawl_common"
require "../_raw/raw_ys_user"
require "../data/ys_user"

class YS::CrawlYsuser < CrawlTask
  UPSERT_SQL = YsUser.upsert_sql(YsUser::RAW_UPSERT_FIELDS)

  def db_seed_tasks(json : String)
    return if json == "不存在该用户"
    args = RawYsUser.from_raw_json(json).changeset
    YsUser.open_tx(&.exec(UPSERT_SQL, args: args))
  end

  def self.gen_link(u_id : Int32)
    "https://api.yousuu.com/api/user/#{u_id}/info"
  end

  DIR = "var/ysraw/users"
  Dir.mkdir_p(DIR)

  def self.gen_path(u_id : Int32)
    "#{DIR}/#{u_id}.latest.json.zst"
  end

  def self.run!(argv = ARGV)
    queue = gen_queue
    new(false).crawl!(queue)
  end

  def self.gen_queue
    u_ids = [] of Int32
    fresh = (Time.utc - 1.day).to_unix

    YsUser.open_db do |db|
      sql = <<-SQL
        select id, rtime from users
        order by (like_count + star_count) desc
      SQL

      db.query_each(sql) do |rs|
        id, rtime = rs.read(Int32, Int64)
        fresh -= 60 # add 1 minute
        u_ids << id if rtime < fresh
      end
    end

    u_ids.map_with_index(1) do |u_id, index|
      Entry.new(
        link: gen_link(u_id),
        path: gen_path(u_id),
        name: "#{index}/#{u_ids.size}"
      )
    end
  end

  run!(ARGV)
end
