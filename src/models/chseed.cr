require "./_models"
require "./nvinfo"

class CV::Models::Chseed
  include Clear::Model
  self.table = "chseeds"

  primary_key type: :serial
  belongs_to nvinfo : Nvinfo, foreign_key_type: Int32

  column seed : String
  column sbid : String

  column _order : Int32, presence: false
  column status : Int32, presence: false

  column update_tz : Int64, presence: false
  column access_tz : Int64, presence: false

  column word_count : Int32, presence: false
  column chap_count : Int32, presence: false

  column view_count : Int32, presence: false
  column read_count : Int32, presence: false

  timestamps

  def set_status(value : Int32, force : Bool = false) : Nil
    self.status = value if force || value > status_column.value(0)
  end

  def set_update_tz(value : Int64, force : Bool = false) : Nil
    self.update_tz = value if force || value > update_tz_column.value(0)
  end

  def set_access_tz(value : Int64, force : Bool = false) : Nil
    self.access_tz = value if force || value > access_tz_column.value(0)
  end

  def self.upsert!(seed : String, sbid : String) : self
    unless model = find({seed: seed, sbid: sbid})
      model = new({seed: seed, sbid: sbid})
      yield model
      model.save!
    end

    model
  end
end
