require "./_models"
require "./serial"
require "./source"

# Chapter info
class Chivi::Chinfo
  include Clear::Model
  self.table = "chinfos"

  primary_key type: :serial
  timestamps

  belongs_to source : Source, foreign_key_type: Int32

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

  def self.glob(source_id : Int32, limit = 50, offset = 0, order_by = :asc)
    query.where(source_id: source_id)
      .limit(limit).offset(offset)
      .order_by("_ord", order_by)
  end

  def self.bulk_upsert!(source : Source, new_chaps : Array(String), force : Bool = false) : Nil
    return if !force && source.chap_count == new_chaps.size

    old_chaps = glob(source.id, limit: 100000).to_a

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
        source: source, _ord: (idx + 1) * 10, scid: new_scid, text: new_text,
      })

      chinfo.save! do |qry|
        qry.on_conflict("(source_id, _ord)").do_update do |upd|
          upd.set(
            scid: new_scid, text: new_text,
            title: nil, label: nil, uslug: nil)
        end
      end
    end

    if source.chap_count < new_chaps.size
      source.chap_count = new_chaps.size
      source.save!
    end
  end
end
