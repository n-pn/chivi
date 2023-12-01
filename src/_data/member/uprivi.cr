require "../_data"

class CV::Uprivi
  class_getter db : DB::Database = PGDB

  include Crorm::Model
  schema "uprivis", :postgres, strict: false

  field vu_id : Int32, pkey: true

  field p_now : Int16 = -1_i16
  field p_exp : Int64 = 0_i16

  field exp_a : Array(Int64) = [0_i64, 0_i64, 0_i64, 0_i64]
  field mtime : Int64 = 0_i16

  def initialize(@vu_id, @p_now = -1_i16, @p_exp = 0_i64, @mtime = Time.utc.to_unix)
  end

  TSPAN = {
    86400,  # one day in seconds
    129600, # * 1.5,
    172800, # * 2,
    216000, # * 2.5
  }

  def extend_privi!(p_new : Int16, days : Int32, persist : Bool = true)
    t_now = Time.utc.to_unix

    p_new.downto(0) do |privi|
      exp_x = {@exp_a[privi], t_now}.max
      @exp_a[privi] = exp_x + TSPAN[p_new &- privi] * days
    end

    if p_new >= @p_now
      @p_now = p_new
      @p_exp = @exp_a[p_new]
    end

    self.upsert! if persist
  end

  def fix_privi!(persist : Bool = true) : Nil
    return unless @p_now.in?(0..3)
    @mtime = Time.utc.to_unix

    @p_now.downto(0) do |privi|
      break if @exp_a[privi] >= @mtime
      @p_now = privi &- 1
    end

    @p_exp = @p_now >= 0 ? @exp_a[@p_now] : 0_i64
    self.upsert! if persist
  end

  ###

  def self.get(vu_id : Int32)
    self.db.query_one?("select * from #{@@schema.table} where vu_id = $1", vu_id, as: self)
  end

  def self.load!(vu_id : Int32)
    get(vu_id) || new(vu_id)
  end
end
