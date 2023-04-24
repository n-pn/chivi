require "colorize"
require "../../src/_data/_data"
require "../../src/_util/hash_util"

DEAD_LINKS = {
  "https://qidian.qpic.cn/qdbimg/1/300",
  "http://pic.hxcdn.net/www/cover0.jpg",
  "http://pic.hxcdn.net/www/cover1.jpg",
}

DEAD_HOSTS = {
  "yododo", "bxwxorg", "biqugee", "jx\\.la", "zhwenpg", "shubaow", "chuantu",
  "jjwxc", "xhhread", "kanshu", "hxcdn", "motie", "nofff", "aixs\\.org",
  "photo\\.qq\\.com", "meowlove", "yuanchuangyanyi", "nosdn0\\.126\\.net",
  "voidtech\\.cn", "read\\.fmx\\.cn", "file\\.ihuayue\\.cn", "picphotos\\.baidu\\.com",
  "wal8\\.com", "s6\\.jpg\\.cm", "aliyuncs\\.com", "sinaimg\\.cn", "pic\\.iqy\\.ink",
  "bvimg\\.com", "qifeng\\.com", "tietuku\\.com", "p\\.yoho\\.cn", "baixiongz\\.com",
  "piimg\\.com", "buimg\\.com",
}

DEAD_HOSTS_RE = Regex.new("#{DEAD_HOSTS.join('|')}")

def dead_link?(link : String)
  DEAD_HOSTS_RE.matches?(link) || DEAD_LINKS.includes?(link)
end

def cache_cover(scover : String) : String
  bcover = HashUtil.digest32(scover, 8)
  status = Process.run("./bin/bcover_cli -i '#{scover}' -n '#{bcover}'", shell: true, output: :inherit, error: :inherit)
  status.success? ? "#{bcover}.webp" : ""
end

input = PGDB.query_all <<-SQL, as: {Int32, String}
  select id, scover from nvinfos
  where scover <> '' and bcover = ''
SQL

input.reject! { |x| dead_link?(x[1]) }
input.shuffle!

w_size = 16
q_size = input.size

workers = Channel({Int32, String, Int32}).new(q_size)
results = Channel(Nil).new(w_size)

w_size.times do
  spawn do
    loop do
      wn_id, scover, idx = workers.receive
      bcover = cache_cover(scover)
      PGDB.exec "update nvinfos set bcover = $1 where id = $2", bcover, wn_id
      puts "- #{idx}/#{q_size} <#{wn_id}> #{scover.colorize.blue} => [#{bcover.colorize.yellow}]"
    rescue err
      Log.error(exception: err) { err.message.colorize.red }
    ensure
      results.send(nil)
    end
  end
end

input.each_with_index(1) { |(wn_id, scover), idx| workers.send({wn_id, scover, idx}) }
q_size.times { results.receive }
