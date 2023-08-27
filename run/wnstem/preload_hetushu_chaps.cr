require "sqlite3"
require "../../src/tasks/remote/shared/rmseed"

DB3_DIR = "/2tb/var.chivi/zchap/globs/!hetushu"
HTM_DIR = "/2tb/var.chivi/.keep/wnchap/www.hetushu.com"
TXT_DIR = "var/texts/rgbks/!hetushu.com"

def preload_book(seed : Rmseed, bid : Int32)
  db_path = "#{DB3_DIR}/#{bid}.db3"
  return unless File.file?(db_path)

  all_ids = DB.open("sqlite3:#{db_path}", &.query_all("select s_cid from chaps", as: String))

  total = all_ids.size

  txt_dir = "#{TXT_DIR}/#{bid}"
  all_ids -= Dir.children(txt_dir).map!(&.sub(".gbk", "")) if File.directory?(txt_dir)

  htm_dir = "#{HTM_DIR}/#{bid}"
  Dir.mkdir_p(htm_dir)

  all_ids -= Dir.children(htm_dir).map!(&.sub(".htm", ""))

  puts "- total: #{total}, missing: #{all_ids.size}"

  q_size = all_ids.size
  w_size = q_size
  w_size = 6 if w_size > 6

  workers = Channel({String, String, Int32}).new(q_size)
  results = Channel(Nil).new(w_size)

  w_size.times do
    spawn do
      loop do
        save_path, chap_link, idx = workers.receive

        seed.save_page(chap_link, save_path)
        puts "- #{idx}/#{q_size}  #{chap_link.colorize.blue} => [#{save_path}]"
      rescue err
        Log.error(exception: err) { err.message.colorize.red }
      ensure
        results.send(nil)
      end
    end
  end

  all_ids.each_with_index(1) do |cid, idx|
    save_path = "#{htm_dir}/#{cid}.htm"
    chap_path = seed.conf.make_chap_path(bid, cid)
    workers.send({save_path, chap_path, idx})
  end

  q_size.times { results.receive }
end

seed = Rmseed.from("www.hetushu.com")

seed.get_mbid.to_i.downto(1) do |bid|
  preload_book(seed, bid)
end
