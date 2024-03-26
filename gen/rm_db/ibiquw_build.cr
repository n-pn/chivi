require "../../src/rdapp/data/czdata"

struct Meta
  include JSON::Serializable
  getter id : String
  getter q : Float32
  getter title : String
  getter author : String

  def after_initialize
    @title = CharUtil.canonize(title)
    @author = CharUtil.canonize(author)
  end
end

def skip_blank?(title : String)
  case title
  when "章节目录", "全部章节", "正文", "正文卷"
    .starts_with?("---"), .includes?("最新章节"), .ends_with?("》正文")
    true
  else
    puts title.colorize.red
    false
  end
end

class Entry
  include JSON::Serializable

  getter text : String
  getter meta : Meta

  def after_initialize
    @text = HTML.unescape(@text)
  end

  getter fname : String do
    "#{meta.id}__#{meta.title}__#{meta.author}__#{meta.q}"
  end

  getter chaps : Array(RD::Czdata) do
    items = [] of RD::Czdata

    @text.split("\n------------\n\n") do |body|
      body = body.lchop("正文 正文_")

      lines = body.lines.map(&.strip).reject!(&.empty?)
      next if lines.empty?

      if lines.size == 1
        title = lines.first
        next if skip_blank?(title)
      end

      items << RD::Czdata.new(
        ch_no: items.size + 1,
        title: lines[0],
        chdiv: "",
        _user: "!ibiquw.com",
        ztext: lines.size > 1 ? lines.join('\n') : "",
      )
    end

    items
  end
end

def import_jsonl(fpath : String)
  File.each_line(fpath) do |json|
    entry = Entry.from_json(json)
    db_path = "/2tb/zroot/rm_db/ibiquw.com/#{entry.fname}.db3"

    chaps = entry.chaps

    RD::Czdata.db(db_path).open_tx { |db| chaps.each(&.upsert!(db: db)) }
    puts "#{entry.fname}: #{chaps.size.colorize.yellow} saved!"
  end
end

# DIR = "/media/nipin/Check/Storage/RyokoAI_CNNovel125K"
# Dir.glob("#{DIR}/*.jsonl").each { |fpath| import_jsonl(fpath) }
