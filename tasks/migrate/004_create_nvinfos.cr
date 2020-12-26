require "clear"

class Chivi::Migration::CreateNvinfosTable
  include Clear::Migration

  def change(dir)
    create_table(:nvinfos, id: :serial) do |t|
      t.column :author_id, :integer, null: false
      t.column :btitle_id, :integer, null: false

      t.column :zh_slug, :string, unique: true, null: false
      t.column :hv_slug, :string, unique: true, null: false
      t.column :vi_slug, :string, unique: true

      t.column :vi_bgenres, :string, array: true, null: false, default: "'{}'"
      t.column :bgenre_ids, :integer, array: true, null: false, default: "'{}'"

      t.column :intro_by, :string
      t.column :zh_intro, :text
      t.column :vi_intro, :text

      t.column :status, :int32, null: false, default: 0
      t.column :shield, :int32, null: false, default: 0

      t.column :cover_name, :string
      t.column :yousuu_bid, :string
      t.column :origin_url, :string

      t.column :word_count, :int32, null: false, default: 0
      t.column :chap_count, :int32, null: false, default: 0

      t.column :view_count, :int32, null: false, default: 0
      t.column :read_count, :int32, null: false, default: 0

      t.column :nvmark_count, :int32, null: false, default: 0

      t.column :zh_voters, :int32, null: false, default: 0
      t.column :zh_rating, :int32, null: false, default: 0

      t.column :vi_voters, :int32, null: false, default: 0
      t.column :vi_rating, :int32, null: false, default: 0

      t.column :cv_voters, :int32, null: false, default: 0, index: true
      t.column :cv_rating, :int32, null: false, default: 0, index: true

      t.column :cv_weight, :int32, null: false, default: 0, index: true

      t.column :update_tz, :int64, null: false, default: 0, index: true
      t.column :access_tz, :int64, null: false, default: 0, index: true

      t.timestamps

      t.index [:author_id, :btitle_id], unique: true
      t.index "bgenre_ids gin__int_ops", using: :gin
    end
  end
end
