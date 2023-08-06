ENV["CV_ENV"] = "production" unless ARGV.includes?("--test")

require "./_crawl_common"
require "../../zroot/json_parser/raw_ysuser"

class CrawlYsuser < CrawlTask
  def db_seed_tasks(entry : Entry, json : String, hash : UInt32)
    CrUtil.post_raw_data("users/info?rtime=#{Time.utc.to_unix}", json)
    # TODO: save to sqlite3 database
  end

  def self.gen_link(yu_id : Int32)
    "https://api.yousuu.com/api/user/#{yu_id}/info"
  end

  DIR = "var/.keep/yousuu/user-infos"
  Dir.mkdir_p(DIR)

  def self.gen_path(yu_id : Int32)
    "#{DIR}/#{yu_id}/latest.json"
  end

  def self.run!(argv = ARGV)
    queue = gen_queue.reject!(&.existed?(1.days))
    new(false).crawl!(queue)
  end

  def self.gen_queue
    u_ids = [] of Int32
    fresh = (Time.utc - 1.day).to_unix

    sql = <<-SQL
      select id, info_rtime from ysusers
      order by (like_count + star_count) desc
    SQL

    PGDB.query_each(sql) do |rs|
      yu_id, rtime = rs.read(Int32, Int64)
      fresh -= 60 # add 1 minute
      u_ids << yu_id if rtime < fresh
    end

    u_ids.map_with_index(1) do |yu_id, index|
      Entry.new(
        link: gen_link(yu_id),
        path: gen_path(yu_id),
        name: "#{index}/#{u_ids.size}"
      )
    end
  end

  run!(ARGV)
end
