require "../_base"
require "./unotif"

require "../dboard/dtopic"
require "../dboard/gdroot"

class CV::Memoir
  enum Type : Int16
    Viuser = 1

    Gdroot = 10
    Gdrepl = 11

    Dtopic = 12
    # Dboard = 15

    Author = 30
    Wnovel = 31
    Wnseed = 35

    Vilist = 41
    Vicrit = 42

    Ysuser = 140
    Yslist = 141
    Yscrit = 142
    Ysrepl = 143

    def self.by_target(target)
      case target
      when CV::Gdrepl then Gdrepl
      when CV::Dtopic then Dtopic
      when CV::Vicrit then Vicrit
      when CV::Vilist then Vilist
      else                 raise "unknown type"
      end
    end
  end

  include Clear::Model
  self.table = "memoirs"

  primary_key type: :serial

  column viuser_id : Int32 = 0
  column target_type : Int16 = 0
  column target_id : Int32 = 0

  column liked_at : Int64 = 0
  column track_at : Int64 = 0

  column viewed_at : Int64 = 0 # user last target visited at
  column tagged_at : Int64 = 0 # user get called in context

  column extra : String? = nil

  def target
    self.class.target(Type.new(self.target_type), self.target_id)
  end

  ####

  def self.target(type : Type, o_id : Int32)
    case type
    when .rpnode? then Gdrepl.load!(id: o_id)
    when .dtopic? then Dtopic.load!(id: o_id)
    when .vicrit? then Vicrit.load!(id: o_id)
    when .vilist? then Vilist.load!(id: o_id)
    else               raise "unsupported type #{type}"
    end
  end

  ####

  def self.load(viuser_id : Int32, target)
    load(viuser_id, Type.by_target(target), target.id)
  end

  def self.load(viuser_id : Int32, target_type : Type, target_id : Int32) : self
    params = {viuser_id: viuser_id, target_type: target_type.value, target_id: target_id}
    self.find(params) || self.new(params)
  end

  def self.glob(user_id : Int32, target_type : Type, target_ids : Array(Int32))
    self.query
      .where("viuser_id = ?", user_id)
      .where("target_type = ?", target_type.value)
      .where("target_id = any(?)", target_ids)
  end
end
