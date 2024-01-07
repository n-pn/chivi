require "../_data"

class Uquota
  class_getter db : DB::Database = PGDB

  include Crorm::Model
  schema "uquotas", :postgres, strict: false

  field vu_id : Int32, pkey: true
  field idate : Int32, pkey: true

  field privi_bonus : Int64 = 0
  field vcoin_bonus : Int64 = 0
  field karma_bonus : Int64 = 0

  field quota_limit : Int64 = 0, auto: true
  field quota_using : Int64 = 0

  field mtime : Int64 = Time.utc.to_unix

  def initialize(@vu_id, @idate = Uquota.gen_idate)
  end

  ADD_USING_SQL = <<-SQL
    insert into uquotas(vu_id, idate, mtime, quota_using)
    values ($1, $2, $3, $4)
    on conflict (vu_id, idate) do update set
      mtime = excluded.mtime,
      quota_using = uquotas.quota_using + excluded.quota_using
    returning quota_using, quota_limit
  SQL

  def add_using!(using : Int32, @mtime = Time.utc.to_unix)
    @quota_using, @quota_limit = @@db.query_one ADD_USING_SQL, @vu_id, @idate, @mtime, using, as: {Int64, Int64}
  end

  ADD_KARMA_SQL = <<-SQL
    insert into uquotas(vu_id, idate, mtime, karma_bonus)
    values ($1, $2, $3, $4)
    on conflict (vu_id, idate) do update set
      mtime = excluded.mtime,
      karma_bonus = uquotas.karma_bonus + excluded.karma_bonus
    returning karma_bonus, quota_limit
  SQL

  def add_karma!(karma : Int32, @mtime = Time.utc.to_unix)
    @karma_bonus, @quota_limit = @@db.query_one ADD_KARMA_SQL, @vu_id, @idate, @mtime, karma, as: {Int64, Int64}
  end

  def self.gen_idate(time = Time.local)
    time.year * 10000 + time.month * 100 + time.day
  end

  def self.find(vu_id, idate = gen_idate)
    query = "select * from uquotas where vu_id = $1 and idate = $2"
    @@db.query_one? query, vu_id, idate, as: self
  end

  def self.user_info(vu_id : Int32)
    query = "select privi, vcoin from viusers where id = $1"
    privi, vcoin = @@db.query_one query, vu_id, as: {Int32, Float64}
    # TODO: remove + 1 statement after increase privi globally
    {privi + 1, (vcoin * 1000).round.to_i}
  end

  def self.privi_bonus(vu_id : Int32)
    privi = @@db.query_one "select privi from viusers where id = $1", vu_id, as: Int32
  end

  def self.load(vu_id : Int32, idate = gen_idate)
    self.find(vu_id, idate) || begin
      model = new(vu_id, idate)

      privi, vcoin = self.user_info(vu_id)

      model.privi_bonus = 100_000 * 2 << (privi - 1)
      model.vcoin_bonus = 100 * vcoin

      model.upsert!
    end
  end
end
