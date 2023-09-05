require "crorm"
require "../_util/hash_util"

class ZR::Wntext
  class Zline
    include Crorm::Model
    schema "zlines", :sqlite, multi: true

    field line : String
    field z_id : Int64

    def initialize(@line)
      @z_id = Has.fnv_1a_64(line).unsafe_as(Int64)
    end

    ###

    def self.db_path(wn_id : Int32 | String)
      "var/wnapp/txt_wn/#{wn_id}-ztext.db3"
    end

    class_getter init_sql = <<-SQL
      create table zlines(
        'z_id' bigint not null primary key,
        'line' varchar not null
      );
    SQL
  end

  class Zpart
    include Crorm::Model
    schema "zparts", :sqlite, multi: true

    field ch_no : Int32, pkey: true
    field p_idx : Int32, pkey: true

    field cksum : String, pkey: true
    field sname : String, pkey: true

    field z_ids : Bytes = Bytes[]

    def initialize(@ch_no, @p_idx, @cksum, @sname)
    end

    # def upsert!(query : String = @@schema.upsert_stmt,
    #             db : DB_ = self.class.db)
    #   db.write_one(query, @ch_no, @p_idx, @cksum, @sname, @z_ids, as: self.class)
    # end

    def line_ids
      @z_ids.unsafe_slice_of(UInt64)
    end

    ###
    def self.db_path(wn_id : Int32 | String)
      "var/wnapp/txt_wn/#{wn_id}-zpart.db3"
    end

    class_getter init_sql = <<-SQL
      create table zparts(
        ch_no int not null,
        p_idx int not null,

        cksum varchar not null,
        sname varchar not null,

        z_ids blob not null,

        primary key (ch_no, p_idx, cksum, sname)
      );
    SQL

    def self.from_file(fpath : String, sname : String)
      *_, wn_id, fname = fpath.split('/')
      ch_no, cksum, p_idx = fname.split('-')
      p_idx = p_idx.split('.').first.to_i

      zchap = new(ch_no.to_i, p_idx, cksum, sname)

      z_ids = File.read_lines(fpath).map { |x| HashUtil.fnv_1a_64(x) }
      zchap.z_ids = Slice(UInt64).new(z_ids.size) { |i| z_ids[i] }.to_unsafe_bytes

      zchap
    end

    # zchap = from_file "var/wnapp/chtext/1/10-5nhts6-1.txt", "~chivi"
    # # puts zchap.z_ids

    # self.db(1).open_rw do |db|
    #   puts zchap.upsert!(db: db).line_ids
    # end
  end
end
