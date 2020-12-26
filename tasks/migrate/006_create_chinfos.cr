require "clear"

class Chivi::Migration::CreateChinfos
  include Clear::Migration

  def change(dir)
    create_table(:chinfos, id: :serial) do |t|
      t.column :chseed_id, :integer, null: false

      t.column :_ord, :integer, null: false
      t.column :scid, :string, null: false
      t.column :text, :string, null: false

      t.column :title, :string
      t.column :label, :string
      t.column :uslug, :string

      t.column :update_tz, :int64, null: false, default: 0
      t.column :access_tz, :int64, null: false, default: 0

      t.column :word_count, :integer, null: false, default: 0
      t.column :read_count, :integer, null: false, default: 0

      t.timestamps

      t.index [:chseed_id, :_ord], unique: true
      t.index [:chseed_id, :scid]
    end
  end
end
