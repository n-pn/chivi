require "clear"

class Chivi::Migration::CreateChtitles
  include Clear::Migration

  def change(dir)
    create_table(:chtitles, id: :serial) do |t|
      t.column :serial_id, :integer, null: false, index: true
      t.column :source_id, :integer, null: false

      t.column :scid, :string, null: false
      t.index [:source_id, :scid], unique: true

      t.column :_index, :integer, null: false, default: 0
      t.column :status, :integer, null: false, default: 0

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
