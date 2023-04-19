require "./_crawl_common"
require "../_raw/raw_ys_user"

class YS::CrawlYsuser < CrawlTask
  def self.upsert_user_info(json : String, rtime : Time)
    post_raw_data("/_ys/users/info?rtime=#{rtime.to_unix}", json)
  end

  def db_seed_tasks(entry : Entry, json : String)
    self.class.upsert_user_info(json, Time.utc)
  rescue ex
    puts ex
  end

  def self.gen_link(yu_id : Int32)
    "https://api.yousuu.com/api/user/#{yu_id}/info"
  end

  DIR = "var/ysraw/users"
  Dir.mkdir_p(DIR)

  def self.gen_path(yu_id : Int32)
    "#{DIR}/#{yu_id}.latest.json.zst"
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

    PG_DB.query_each(sql) do |rs|
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

  def self.seed_crawled!(latest_only = true)
    files = Dir.glob("#{DIR}/*.zst")
    files.select!(&.ends_with?("latest.json.zst")) if latest_only

    files.each do |file|
      puts file
      json = read_zstd(file)
      rtime = File.info(file).modification_time
      upsert_user_info(json, rtime)
    rescue ex
      puts ex.colorize.red
      File.delete(file)
    end
  end

  if ARGV.includes?("--seed")
    seed_crawled!(ARGV.includes?("--latest"))
  else
    run!(ARGV)
  end
end
