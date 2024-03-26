require "../../src/rdapp/data/czdata"

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
  getter title : String

  def after_initialize
    @title = CharUtil.canonize(title)
    @text = HTML.unescape(@text)
  end

  getter chaps : Array(RD::Czdata) do
    items = [] of RD::Czdata

    @text.split("\r\n------------\r\n\r\n") do |body|
      body = body.lchop("正文 正文_")

      lines = body.split(/\R/).map(&.strip).reject!(&.empty?)
      next if lines.empty?

      if lines.size == 1
        title = lines.first
        next if skip_blank?(title)
      end

      items << RD::Czdata.new(
        ch_no: items.size + 1,
        title: lines[0],
        chdiv: "",
        _user: "!tsinghua",
        ztext: lines.size > 1 ? lines.join('\n') : "",
      )
    end

    items
  end
end

def import_jsonl(fpath : String)
  File.each_line(fpath) do |json|
    entry = Entry.from_json(json)
    db_path = "/2tb/zroot/rm_db/tsinghua/#{entry.title}.db3"

    chaps = entry.chaps

    RD::Czdata.db(db_path).open_tx { |db| chaps.each(&.upsert!(db: db)) }
    puts "#{entry.title}: #{chaps.size.colorize.yellow} saved!"
  end
end

DIR = "/2tb/fetch/tsinghua"
Dir.glob("#{DIR}/*.jsonl").each { |fpath| import_jsonl(fpath) }
