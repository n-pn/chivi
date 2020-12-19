require "clear"

class Chivi::Migration::CreateSerialsTable
  include Clear::Migration

  def change(dir)
    create_table(:serials, id: :serial) do |t|
      t.column :zh_slug, :string, unique: true, null: false
      t.column :hv_slug, :string, unique: true, null: false
      t.column :vi_slug, :string, unique: true

      t.column :author_id, :integer, null: false
      t.column :btitle_id, :integer, null: false
      t.index [:author_id, :btitle_id], unique: true

      t.column :vi_bgenres, :string, array: true, null: false, default: "'{}'"
      t.column :bgenre_ids, :integer, array: true, null: false, default: "'{}'"
      t.index "bgenre_ids gin__int_ops", using: :gin

      t.column :zh_intro, :text
      t.column :intro_by, :text
      t.column :vi_intro, :text

      t.column :hidden, :int32, null: false, default: 0
      t.column :status, :int32, null: false, default: 0

      t.column :update_at, :int64, null: false, default: 0, index: true
      t.column :access_at, :int64, null: false, default: 0, index: true

      t.column :zh_voters, :int32, null: false, default: 0
      t.column :zh_rating, :real, null: false, default: 0

      t.column :vi_voters, :int32, null: false, default: 0
      t.column :vi_rating, :real, null: false, default: 0

      t.column :word_count, :int32, null: false, default: 0
      t.column :chap_count, :int32, null: false, default: 0

      t.column :view_count, :int32, null: false, default: 0
      t.column :read_count, :int32, null: false, default: 0

      t.column :review_count, :int32, null: false, default: 0
      t.column :follow_count, :int32, null: false, default: 0

      t.column :popularity, :int32, null: false, default: 0, index: true

      t.column :cover_name, :string
      t.column :yousuu_bid, :string
      t.column :origin_url, :string

      t.timestamps
    end
  end
end
