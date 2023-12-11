require "http/client"

require "../../_data/zr_db"

require "../../_util/hash_util"
require "../../_util/char_util"
require "../../_util/time_util"

require "../_raw/*"

class MT::MCache
  class_getter db : DB::Database = ZR_DB

  include Crorm::Model

  schema "mcache", :postgres

  field rid : Int64, pkey: true
  field ver : Int16, pkey: true
  field tid : Int32, pkey: true

  field tok : Array(String)
  field con : RawCon = MT::RawCon.new("X"), converter: MT::RawCon
  field dep : String = ""
  field ner : String = "" # msra + ontonotes

  field mtime : Int32 = 0 # last modified at

  def initialize(@ver, @tok, @mtime = TimeUtil.cv_mtime)
    @rid = self.class.gen_rid(tok)
    @tid = self.class.gen_tid(tok)
  end

  def dep=(dep : Array(RawDep))
    @dep = dep.map { |x| "#{x.dep}/#{x.idx}" }.join('\t')
  end

  def ner=(ner : Array(RawEnt))
    @ner = ner.map { |x| "#{x.kind}/#{x.zstr}" }.uniq!.join('\t')
  end

  UPSERT_CON_SQL = @@schema.upsert_stmt(keep_fields: ["con"])

  def upsert_con!(db : Crorm::DBX = @@db)
    self.upsert!(query: UPSERT_CON_SQL, db: db)
  end

  ###

  def self.gen_rid(tok : String)
    HashUtil.fnv_1a_64(tok).unsafe_as(Int64)
  end

  def self.gen_rid(tok : Array(String))
    HashUtil.cksum_64(tok).unsafe_as(Int64)
  end

  def self.gen_tid(tok : Array(String))
    HashUtil.cksum_32(tok, '\t').unsafe_as(Int32)
  end

  FIND_BY_STR_SQL = <<-SQL
    select * from mcache
    where rid = $1 and ver = $2
    order by mtime desc
    limit 1
    SQL

  @[AlwaysInline]
  def self.find(inp : String, ver : Int16 = 1_i16)
    @@db.query_one? FIND_BY_STR_SQL, gen_rid(inp), ver, as: self
  end

  FIND_BY_TOK_SQL = <<-SQL
    select * from mcache
    where rid = $1 and ver = $2 and tok = $3
    order by mtime desc
    limit 1
    SQL

  @[AlwaysInline]
  def self.find(inp : Array(String), ver : Int16 = 1_i16)
    @@db.query_one? FIND_BY_TOK_SQL, gen_rid(inp), ver, inp, as: self
  end

  ###

  SCAN_BY_STR_SQL = <<-SQL
    select * from mcache
    where rid = any ($1) and ver = $2
    order by mtime desc
    SQL

  def self.find_all(inp : Array(String), ver : Int16 = 1_i16)
    rids = inp.map { |str| gen_rid(str) }
    hash = @@db.query_all(SCAN_BY_STR_SQL, rids, ver, as: self).group_by(&.rid)

    rids.map { |rid| hash[rid]?.try(&.first) }
  end

  def self.find_all(inp : Array(Array(String)), ver : Int16 = 1_i16)
    rids = inp.map { |x| gen_rid(x) }
    hash = @@db.query_all(SCAN_BY_STR_SQL, rids, ver, as: self).group_by(&.rid)

    rids.map_with_index do |rid, i|
      next unless list = hash[rid]?
      list.find(&.tok.== inp[i])
    end
  end

  def self.find_all!(inp : Array(String), ver : Int16 = 1_i16)
    indexes = [] of Int32
    missing = String::Builder.new

    rids = inp.map { |str| gen_rid(str.gsub('　', "")) }
    hash = @@db.query_all(SCAN_BY_STR_SQL, rids, ver, as: self).group_by(&.rid)

    outputs = rids.map_with_index do |rid, idx|
      hash[rid]?.try(&.first) || begin
        missing << '\n' unless indexes.empty?

        str = inp[idx]
        missing << str
        indexes << idx
        new(ver: ver, tok: [str])
      end
    end

    return outputs if indexes.empty?
    missing = missing.to_s

    raw_data = RawMtlBatch.call_hanlp(missing, ver: ver)
    new_data = [] of self

    raw_data.tok.each_with_index do |tok, idx|
      entry = new(ver: ver, tok: tok)
      entry.con = raw_data.con[idx]

      raw_data.dep[idx]?.try { |dep| entry.dep = dep }
      entry.ner = raw_data.ner_msra[idx].concat(raw_data.ner_onto[idx])

      outputs[indexes[idx]] = entry
      new_data << entry
    end

    @@db.transaction { |tx| new_data.each(&.upsert!(db: tx.connection)) }

    outputs
  end
end
