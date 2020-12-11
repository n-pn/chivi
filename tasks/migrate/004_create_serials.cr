require "clear"

class Chivi::Migration::CreateSerials
  include Clear::Migration

  def change(dir)
    create_table(:serials) do |t|
      t.column :hv_slug, :string, unique: true, null: false
      t.column :vi_slug, :string, unique: true

      t.column :author_id, :integer, null: false
      t.column :btitle_id, :integer, null: false
      t.index [:author_id, :btitle_id], unique: true

      t.column :bgenre_ids, :integer, array: true, null: false, default: "'{}'"
      t.index "bgenre_ids gin__int_ops", using: :gin
      # t.column :source_ids, :integer, array: true, null: false, default: "'{}'"

      t.column :zh_intro, :text
      t.column :vi_intro, :text
      t.column :intro_by, :text

      t.column :hidden, :integer, null: false, default: 0
      t.column :status, :integer, null: false, default: 0

      t.column :update_at, :integer, null: false, default: 0, index: true
      t.column :access_at, :integer, null: false, default: 0, index: true

      t.column :zh_voters, :integer, null: false, default: 0
      t.column :zh_rating, :integer, null: false, default: 0

      t.column :vi_voters, :integer, null: false, default: 0
      t.column :vi_rating, :integer, null: false, default: 0

      t.column :word_count, :integer, null: false, default: 0
      t.column :chap_count, :integer, null: false, default: 0

      t.column :view_count, :integer, null: false, default: 0
      t.column :read_count, :integer, null: false, default: 0

      t.column :review_count, :integer, null: false, default: 0
      t.column :follow_count, :integer, null: false, default: 0

      t.column :popularity, :integer, null: false, default: 0, index: true

      t.column :cover_name, :string
      t.column :yousuu_bid, :string
      t.column :origin_url, :string

      t.timestamps
    end
  end
end
