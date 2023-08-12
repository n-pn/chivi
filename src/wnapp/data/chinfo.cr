require "crorm"
require "../../_util/text_util"

class WN::Chinfo
  class_getter init_sql = <<-SQL
    pragma journal_mode = WAL;

    CREATE TABLE IF NOT EXISTS chinfos(
      ch_no int not null PRIMARY KEY,
      rpath text NOT NULL DEFAULT '',
      --
      cksum text NOT NULL DEFAULT '',
      sizes text NOT NULL DEFAULT '',
      --
      ztitle text NOT NULL DEFAULT '',
      zchdiv text NOT NULL DEFAULT '',
      --
      vtitle text NOT NULL DEFAULT '',
      vchdiv text NOT NULL DEFAULT ''
      --
      mtime bigint NOT NULL DEFAULT 0,
      uname text NOT NULL default '',
      --
      _flag int NOT NULL default 0
    );
    SQL

  def self.db_path(sname : String, sn_id : String)
    "var/zroot/wnchap/#{sname}/#{sn_id}.db3"
  end

  ###

  include Crorm::Model
  schema "chinfos", :sqlite, multi: true

  field ch_no : Int32, pkey: true
  field rpath : String = "" # relative or absolute remote path

  field ztitle : String = "" # chapter zh title name
  field zchdiv : String = "" # chapter zh division (volume) name

  field vtitle : String = "" # chapter vi title name
  field vchdiv : String = "" # chapter vi division (volume) name

  field cksum : String = "" # check sum of raw chapter text
  field sizes : String = "" # char_count of for title + each part joined by a single ' '

  field mtime : Int64 = 0_i64 # last modified at, optional
  field uname : String = ""   # last modified by, optional

  def initialize(@ch_no)
  end

  def initialize(@ch_no, @rpath, @ztitle, @zchdiv)
  end

  ####

  def self.clean_chdiv(chdiv : String)
    chdiv.gsub(/《.*》/, "").gsub(/\n|\t|\s{3,}/, "  ").strip
  end

  NUMS = "零〇一二两三四五六七八九十百千"
  VOLS = "集卷季"

  DIVS = {
    /^(第?[#{NUMS}\d]+[#{VOLS}].*?)(第?[#{NUMS}\d]+[章节幕回折].*)$/,
    # /^(第?[#{NUMS}\d]+[#{VOLS}].*?)(（\p{N}+）.*)$/,
    /^【(第?[#{NUMS}\d]+[#{VOLS}])】(.+)$/,
  }

  def self.split_title(title : String, chdiv = "") : Tuple(String, String)
    title = TextUtil.clean_and_trim(title)
    return {title, chdiv} unless chdiv.empty?

    DIVS.each do |regex|
      next unless match = regex.match(title)
      return {match[2].lstrip, match[1].rstrip}
    end

    {title, chdiv}
  end
end
