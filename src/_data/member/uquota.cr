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

  def add_quota_spent!(using : Int32, @mtime = Time.utc.to_unix)
    @quota_using, @quota_limit = @@db.query_one ADD_USING_SQL, @vu_id, @idate, @mtime, using, as: {Int64, Int64}
  end

  ADD_VCOIN_SQL = <<-SQL
    insert into uquotas(vu_id, idate, mtime, vcoin_bonus)
    values ($1, $2, $3, $4)
    on conflict (vu_id, idate) do update set
      mtime = excluded.mtime,
      vcoin_bonus = uquotas.vcoin_bonus + excluded.vcoin_bonus
    returning vcoin_bonus, quota_limit
  SQL

  def add_vcoin_bonus!(bonus : Int32, @mtime = Time.utc.to_unix)
    @vcoin_bonus, @quota_limit = @@db.query_one ADD_VCOIN_SQL, @vu_id, @idate, @mtime, bonus, as: {Int64, Int64}
  end

  ADD_KARMA_SQL = <<-SQL
    insert into uquotas(vu_id, idate, mtime, karma_bonus)
    values ($1, $2, $3, $4)
    on conflict (vu_id, idate) do update set
      mtime = excluded.mtime,
      karma_bonus = uquotas.karma_bonus + excluded.karma_bonus
    returning karma_bonus, quota_limit
  SQL

  def add_karma_bonus!(bonus : Int32, @mtime = Time.utc.to_unix)
    @karma_bonus, @quota_limit = @@db.query_one ADD_KARMA_SQL, @vu_id, @idate, @mtime, bonus, as: {Int64, Int64}
  end

  def self.gen_idate(time = Time.local)
    time.year * 10000 + time.month * 100 + time.day
  end

  def self.find(vu_id, idate = gen_idate)
    query = "select * from uquotas where vu_id = $1 and idate = $2"
    @@db.query_one? query, vu_id, idate, as: self
  end

  def self.load(vu_id : Int32, idate = gen_idate)
    self.find(vu_id, idate) || begin
      model = new(vu_id, idate)

      privi = @@db.query_one "select privi from viusers where id = $1", vu_id, as: Int32
      model.privi_bonus = 100_000 * 2 << (privi - 1)

      model.upsert!
    end
  end

  def self.guest_id(client_ip : String) : Int32
    _, _, a, b = client_ip.split('.')
    -a.to_i * 256 - b.to_i
  rescue
    0
  end
end
