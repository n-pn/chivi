require "crorm"

struct MT::Wsterm
  DIR = "var/mt_db"

  class_getter db_path = "#{DIR}/wsterms.db3"

  class_getter init_sql : String = <<-SQL
    CREATE TABLE IF NOT EXISTS wsterms (
      d_id text NOT NULL,
      zstr text NOT NULL,
      --
      wprio int not null default 2,
      ntype text,
      --
      z_out text,
      v_out text,
      --
      uname text NOT NULL DEFAULT '',
      mtime int NOT NULL DEFAULT 0,
      _flag int NOT NULL DEFAULT 0,
      --
      primary key(d_id, zstr)
    ) strict, without rowid;
  SQL

  ###

  include Crorm::Model
  schema "wsterms", :sqlite

  field dname : String, pkey: true
  field a_key : String, pkey: true
  field b_key : String, pkey: true

  field a_vstr : String
  field a_attr : String? = nil

  field b_vstr : String? = nil
  field b_attr : String? = nil

  def initialize(@dname, @a_key, @b_key, @a_vstr, @a_attr, @b_vstr, @b_attr)
  end

  def self.new(dname : String, cols : Array(String))
    new(
      dname: dname,
      a_key: cols[0],
      b_key: cols[1],
      a_vstr: cols[2],
      a_attr: cols[3]?.try { |x| x.empty? ? nil : x },
      b_vstr: cols[4]?.try { |x| x.empty? ? nil : x },
      b_attr: cols[5]?.try { |x| x.empty? ? nil : x },
    )
  end
end
