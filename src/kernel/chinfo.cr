require "./_models"
require "./chseed"

# Chapter info
class Chivi::Chinfo
  include Clear::Model
  self.table = "chinfos"

  primary_key type: :serial

  belongs_to chseed : Chseed, foreign_key_type: Int32

  column scid : String
  column text : String
  column _ord : Int32

  column title : String?
  column label : String?
  column uslug : String?

  column update_at : Int64, presence: false
  column access_at : Int64, presence: false

  column word_count : Int32, presence: false
  column read_count : Int32, presence: false

  timestamps

  def self.glob(chseed_id : Int32, limit = 50, offset = 0, order_by = :asc)
    query.where(chseed_id: chseed_id)
      .limit(limit).offset(offset)
      .order_by("_ord", order_by)
  end

  def self.bulk_upsert!(chseed : Chseed, new_chaps : Array(String), force : Bool = false) : Nil
    return if !force && chseed.chap_count == new_chaps.size

    old_chaps = glob(chseed.id, limit: 100000).to_a

    old_chaps.each_with_index do |old_chap, idx|
      next unless new_chap = new_chaps[idx]?
      new_scid, new_text = new_chap.split('\t')

      next if old_chap.scid == new_scid && old_chap.text == new_text

      old_chap.scid = new_scid
      old_chap.text = new_text

      old_chap.title = nil
      old_chap.label = nil
      old_chap.uslug = nil

      old_chap.save!
    end

    old_chaps.size.upto(new_chaps.size - 1) do |idx|
      next unless new_chap = new_chaps[idx]?

      new_scid, new_text = new_chap.split('\t')

      chinfo = Chinfo.new({
        chseed: chseed, _ord: (idx + 1) * 10, scid: new_scid, text: new_text,
      })

      chinfo.save! do |qry|
        qry.on_conflict("(chseed_id, _ord)").do_update do |upd|
          upd.set(
            scid: new_scid, text: new_text,
            title: nil, label: nil, uslug: nil)
        end
      end
    end

    if chseed.chap_count < new_chaps.size
      chseed.chap_count = new_chaps.size
      chseed.save!
    end
  end
end
