require "clear"

class Chivi::Migration::CreateChinfos
  include Clear::Migration

  def change(dir)
    create_table(:chinfos, id: :serial) do |t|
      t.column :source_id, :integer, null: false

      t.column :scid, :string, null: false
      t.index [:source_id, :scid]

      t.column :_index, :integer, null: false, default: 0
      t.index [:source_id, :_index], unique: true

      t.column :zh_title, :string, null: false
      t.column :vi_title, :string
      t.column :vi_label, :string
      t.column :url_slug, :string

      t.column :update_at, :int64, null: false, default: 0
      t.column :access_at, :int64, null: false, default: 0

      t.column :word_count, :integer, null: false, default: 0
      t.column :read_count, :integer, null: false, default: 0

      t.timestamps
    end
  end
end
