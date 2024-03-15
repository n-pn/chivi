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

  field mtime : Int64 = 0_i64

  def initialize(@vu_id, @idate = Uquota.gen_idate)
  end

  def limit_exceeded?(qcost : Int32 = 0)
    @quota_using + qcost > @quota_limit
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

  ADD_PRIVI_SQL = <<-SQL
    insert into uquotas(vu_id, idate, mtime, privi_bonus)
    values ($1, $2, $3, $4)
    on conflict (vu_id, idate) do update set
      mtime = excluded.mtime,
      privi_bonus = excluded.privi_bonus
    returning quota_limit
  SQL

  def set_privi_bonus!(privi : Int32, @mtime = Time.utc.to_unix)
    @privi_bonus = privi >= 0 ? 100_000_i64 * 2 ** privi : 50_000_i64
    @quota_limit = @@db.query_one ADD_PRIVI_SQL, @vu_id, @idate, @mtime, @privi_bonus, as: Int64
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

  SUBTRACT_VCOIN_SQL = <<-SQL
    update viusers set vcoin = vcoin - $1
    where id = $2 and vcoin >= $1
    returning vcoin
    SQL

  def spend_vcoin!(pad_value = 10_000)
    qdiff = @quota_using - @quota_limit + pad_value
    vcoin = qdiff / 100_000

    return unless @@db.query_one?(SUBTRACT_VCOIN_SQL, vcoin, @vu_id, as: Float64)
    self.add_vcoin_bonus!(bonus: qdiff.to_i)

    vcoin
  end

  #####

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

  @[AlwaysInline]
  def self.gen_idate(time = Time.local)
    time.year * 10000 + time.month * 100 + time.day
  end

  def self.find(vu_id, idate = gen_idate)
    query = "select * from uquotas where vu_id = $1 and idate = $2"
    @@db.query_one? query, vu_id, idate, as: self
  end

  @[AlwaysInline]
  def self.load(vu_id : Int32, vu_ip : String, idate = gen_idate)
    self.load(vu_id == 0 ? guest_id(vu_ip) : vu_id, idate: idate)
  end

  def self.load(vu_id : Int32, idate = gen_idate)
    self.find(vu_id, idate) || begin
      model = new(vu_id, idate)

      if vu_id > 0
        query = "select coalesce(privi, -1) from viusers where id = $1"
        privi = @@db.query_one(query, vu_id, as: Int32)
      else
        privi = -1
      end

      model.set_privi_bonus!(privi)
      model
    end
  end

  def self.guest_id(client_ip : String) : Int32
    _, _, a, b = client_ip.split('.')
    -a.to_i * 256 - b.to_i
  rescue
    0
  end
end
