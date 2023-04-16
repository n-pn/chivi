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

  def create_like_notif!(target : Murepl | Dtopic, from_user : String)
    type = target.is_a?(Murepl) ? :like_repl : :like_dtop

    _undo_tag_ = Unotif.gen_undo_tag(target.viuser_id, type, target.id)
    return if Unotif.find_by_utag(_undo_tag_)

    content, details, link_to = target.gen_like_notif(from_user)
    unotif = Unotif.new(target.viuser_id, content, details.to_json, link_to, _undo_tag_)

    unotif.created_at = Time.unix(self.liked_at)
    unotif.create!
  end

  def remove_like_notif!(target : Murepl | Dtopic)
    type = target.is_a?(Murepl) ? :like_repl : :like_dtop
    Unotif.remove_notif Unotif.gen_undo_tag(target.viuser_id, :type, target.id)
  end

  #

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
