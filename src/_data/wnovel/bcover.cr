class CV::Bcover
  DEAD_LINKS = {
    "https://qidian.qpic.cn/qdbimg/0/300",
    "https://qidian.qpic.cn/qdbimg/1/300",
    "http://pic.hxcdn.net/www/cover0.jpg",
    "http://pic.hxcdn.net/www/cover1.jpg",
  }

  DEAD_HOSTS = {
    "bxwxorg",
    "biqugee",
    "jx\\.la",
    "zhwenpg",
    "shubaow",
    "nofff",
    # "yododo",
    # "jjwxc",
    # "chuantu",
    "xhhread\\.cn",
    "kanshu\\.com",
    "pic\\.hxcdn\\.net",
    "iqing\\.in",
    "motieimg\\.com",
    "pic\\.iqy\\.ink",
    # "aixs\\.org",
    # "photo\\.qq\\.com",
    # "meowlove",
    # "yuanchuangyanyi",
    # "nosdn0\\.126\\.net",
    # "voidtech\\.cn",
    # "read\\.fmx\\.cn",
    # "file\\.ihuayue\\.cn",
    # "picphotos\\.baidu\\.com",
    # "wal8\\.com",
    # "s6\\.jpg\\.cm",
    # "aliyuncs\\.com",
    # "sinaimg\\.cn",
  }

  DEAD_HOSTS_RE = Regex.new("#{DEAD_HOSTS.join('|')}")

  def self.dead_link?(link : String)
    DEAD_HOSTS_RE.matches?(link) || DEAD_LINKS.includes?(link)
  end
end
