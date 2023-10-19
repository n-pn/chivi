require "crorm"
require "../../_util/chap_util"

class RD::Czdata
  class_getter init_sql = <<-SQL
    CREATE TABLE IF NOT EXISTS czdata(
      ch_no int not null,
      cksum bigint NOT NULL,
      --
      title varchar NOT NULL DEFAULT '',
      chdiv varchar NOT NULL DEFAULT '',
      --
      uname varchar NOT NULL default '',
      zorig varchar NOT null default '',
      mtime bigint NOT NULL DEFAULT 0,
      --
      parts varchar NOT null default '',
      sizes varchar NOT NULL DEFAULT '',
      --
      primary key(ch_no, cksum)
    );
    SQL

  CZ_DIR = ENV["CZ_DIR"]? || "var/stems"

  @[AlwaysInline]
  def self.db_path(dname : String)
    "#{CZ_DIR}/#{dname}-ztext.db3"
  end

  ###

  include Crorm::Model
  schema "czdata", :sqlite, multi: true

  field ch_no : Int32 = 0, pkey: true
  field cksum : Int64 = 0_i64, pkey: true

  field title : String = ""
  field chdiv : String = ""

  field uname : String = "" # note: for remote source uname is the seed name
  field zorig : String = "" # note: for remote source, the format is b_id/c_id
  field mtime : Int64 = 0_i64

  field parts : String = ""
  field sizes : String = ""

  def initialize(@ch_no, cbody : String, title : String = "", chdiv : String = "",
                 @uname = "", @zorig = "", @mtime = Time.utc.to_unix)
    cbody = ChapUtil.split_lines(cbody)
    title = cbody.first if title.empty?

    self.set_labels(title, chdiv)
    self.set_czdata(cbody)
  end

  def initialize(@ch_no, cbody : Array(String), title : String = "", chdiv : String = "",
                 @uname = "", @zorig = "", @mtime = Time.utc.to_unix)
    title = cbody.first if title.empty?

    self.set_labels(title, chdiv)
    self.set_czdata(cbody)
  end

  def set_labels(title : String, chdiv : String, cleaned : Bool = false)
    @title, @chdiv = ChapUtil.split_ztitle(title, chdiv: chdiv, cleaned: cleaned)
  end

  def set_czdata(cbody : Array(String))
    @parts, @sizes, @cksum = ChapUtil.split_cztext(cbody)
  end

  ###

  def filename
    "#{@ch_no}-#{ChapUtil.cksum_to_s(@cksum)}.json"
  end
end

# Dir.glob("/www/chivi/xyz/seeds/zxcs.me/split/13442/*.txt").each do |file|
#   chap = RD::Cztext.new(File.read(file))
#   puts chap.parts.size, chap.sizes, chap.cksum_to_s

#   chap_2 = RD::Cztext.from_json(chap.to_json)
#   if chap.cksum != chap_2.cksum
#     puts "!!!: #{file}"
#   end
# end

# lines = File.read_lines("/www/chivi/xyz/seeds/zxcs.me/split/13442/1.txt")

# parts_1, sizes_1, cksum_1 = ChapUtil.split_parts(lines.dup)
# parts_2, sizes_2, cksum_2 = ChapUtil.split_parts_2(lines)

# puts cksum_1 == cksum_2
# puts sizes_1.join(' ') == sizes_2
# puts parts_1.join("\n\n") == parts_2
