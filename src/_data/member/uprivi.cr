require "../_data"

class CV::Uprivi
  class_getter db : DB::Database = PGDB

  include Crorm::Model
  schema "new_uprivis", :postgres, strict: false

  field vu_id : Int32, pkey: true
  field privi : Int16, pkey: true

  field p_til : Int64 = 0_i64
  field mtime : Int64 = 0_i64

  field auto_renew : Bool = false

  def initialize(@vu_id, @privi, @p_til = 0_i64, @mtime = 0_i64)
  end

  def extend!(tspan : Int, t_min = Time.utc.to_unix) : Int64
    @p_til = @p_til < t_min ? t_min &+ tspan : @p_til &+ tspan
    @mtime = Time.utc.to_unix
    self.upsert!(db: @@db)

    @p_til
  end

  TSPAN = {
    86400,  # one day in seconds
    129600, # * 1.5,
    172800, # * 2,
    216000, # * 2.5
  }

  def self.load(vu_id : Int32, privi : Int16)
    self.get(vu_id, privi, db: @@db, &.<< "where vu_id = $1 and privi = $2")
  end

  def self.load!(vu_id : Int32, privi : Int16)
    load(vu_id, privi) || new(vu_id, privi)
  end

  def self.extend!(vu_id : Int32, p_new : Int16, days : Int32, auto_renew = false)
    t_min = Time.utc.to_unix

    pdata = [] of self

    p_new.downto(1) do |p_now|
      tspan = TSPAN[p_new &- p_now] * days
      model = self.load!(vu_id, p_now)
      model.auto_renew = auto_renew
      t_min = model.extend!(tspan: tspan, t_min: t_min)
      pdata << model
    end

    pdata
  end

  def self.max_valid(vu_id : Int32, p_til = Time.utc.to_unix)
    self.get(vu_id, p_til, &.<< "where vu_id = $1 and p_til >= $2 order by privi desc limit 1")
  end
end
