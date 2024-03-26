require "crorm"
require "xxhash"

class ZR::Chfile
  class_getter init_sql = <<-SQL
    pragma journal_mode = WAL;

    CREATE TABLE IF NOT EXISTS chfiles(
      ch_no int not null PRIMARY KEY,
      ---
      fhash text NOT NULL DEFAULT '',
      sizes text NOT NULL DEFAULT '',
      --
      mtime bigint NOT NULL DEFAULT 0,
      uname text not null default ''
    );
    SQL

  def self.db_path(sname : String, sn_id : String)
    "/srv/chivi/zroot/wnovel/#{sname}/#{sn_id}-zfile.db3"
  end

  ###

  include Crorm::Model
  schema "chfiles", :sqlite, multi: true

  field ch_no : Int32, pkey: true

  field fhash : String = "" # raw text file will be stored as "#{ch_no}_#{cpart}-#{fhash}.txt"
  field sizes : String = "" # char_count of for title + each part joined by a single ' '

  field mtime : Int64 = 0_i64 # last modified at, optional
  field uname : String = ""   # last modified by, optional

  def initialize(@ch_no)
  end

  def initialize(@ch_no, ctext : String, @mtime : Int64, @uname = "")
    @fhash = self.class.make_hash(ctext)
    @sizes = ctext.split("\n\n").map(&.size).join(' ')
  end

  def self.make_hash(input : String)
    # NOTE: this is actually not cover the whole range of UInt32, as it can
    # only represent 32 ** 6 = 1073741824 integers
    # but as the chapter count for each novel is as most 10000
    # it does not matter much
    # if we use 7 characters then there will be chance when it overflow the UInt32
    # limit when we convert this back to integer for fast comparision,
    # so it is not worth it to add an extra character

    xxh32 = XXHash.xxh32(input)

    String.build do |io|
      6.times do
        digit = xxh32 % 32
        io << (digit < 10 ? '0' : 'W') + digit
        xxh32 //= 32
      end
    end
  end
end
