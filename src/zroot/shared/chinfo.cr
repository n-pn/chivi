require "crorm"
require "../../_util/text_util"

class ZR::Chinfo
  class_getter init_sql = <<-SQL
    pragma journal_mode = WAL;

    CREATE TABLE IF NOT EXISTS chinfos(
      ch_no int not null PRIMARY KEY,
      ---
      rpath text NOT NULL DEFAULT '',
      s_cid text NOT NULL DEFAULT '',
      --
      title text NOT NULL DEFAULT '',
      chdiv text NOT NULL DEFAULT ''
    );
    SQL

  def self.db_path(sname : String, sn_id : String)
    "var/zroot/wnovel/#{sname}/#{sn_id}-zchap.db3"
  end

  ###

  include Crorm::Model
  schema "chinfos", :sqlite, multi: true

  field ch_no : Int32, pkey: true

  field rpath : String = "" # relative or absolute remote path
  field s_cid : String = "" # remote chapter id extracted from rpath

  field title : String = "" # chapter title name
  field chdiv : String = "" # chapter chdivision (volume) name

  def initialize(@ch_no)
  end

  def initialize(@ch_no, @rpath, @s_cid, @title, @chdiv)
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
