require "../_base"
require "./unotif"

require "../dboard/dtopic"
require "../dboard/murepl"

class CV::Memoir
  enum Type : Int16
    Murepl = 11

    Dtopic = 12
    Dboard = 20
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

  def send_notif!(action : Symbol)
    case symbol
    when :like   then create_like_notif!
    when :unlike then remove_like_notif!
    end
  end

  def target
    case Type.new(target_type)
    when .murepl? then Murepl.load!(id: self.target_id)
    when .dtopic? then Dtopic.load!(id: self.target_id)
    else               raise "unknown type"
    end
  end

  def create_like_notif!(target : Murepl | Dtopic, from_user : String)
    return if target.viuser_id == self.viuser_id

    action = target.is_a?(Murepl) ? Unotif::Action::LikeRepl : Unotif::Action::LikeDtop
    return if Unotif.find(action, target.id, target.viuser_id)

    content, details, link_to = target.gen_like_notif(from_user)

    unotif = Unotif.new(
      viuser_id: target.viuser_id,
      action: action, object_id: target.id, byuser_id: self.viuser_id,
      content: content, details: details.to_json, link_to: link_to,
      created_at: Time.unix(self.liked_at)
    )

    unotif.create!
  end

  def remove_like_notif!(target : Murepl | Dtopic)
    action = target.is_a?(Murepl) ? Unotif::Action::LikeRepl : Unotif::Action::LikeDtop
    Unotif.remove_notif(action, target.id, target.viuser_id)
  end

  ####

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
