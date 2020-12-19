require "clear"

class Chivi::Migration::CreateChinfos
  include Clear::Migration

  def change(dir)
    create_table(:chinfos, id: :serial) do |t|
      t.column :source_id, :integer, null: false

      t.column :text, :string, null: false

      t.column :scid, :string, null: false
      t.index [:source_id, :scid]

      t.column :_ord, :integer, null: false, default: 0
      t.index [:source_id, :_ord], unique: true

      t.column :title, :string
      t.column :label, :string
      t.column :uslug, :string

      t.column :update_at, :int64, null: false, default: 0
      t.column :access_at, :int64, null: false, default: 0

      t.column :word_count, :integer, null: false, default: 0
      t.column :read_count, :integer, null: false, default: 0

      t.timestamps
    end
  end
end
