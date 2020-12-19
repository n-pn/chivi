require "clear"

class Chivi::Migration::CreateSources
  include Clear::Migration

  def change(dir)
    create_table(:sources, id: :serial) do |t|
      t.column :name, :string, null: false
      t.column :sbid, :string, null: false
      t.index [:name, :sbid], unique: true

      t.column :serial_id, :integer, index: true

      t.column :_order, :integer, null: false, default: "0"
      t.column :status, :integer, null: false, default: "0"

      t.column :update_at, :int64, null: false, default: 0
      t.column :access_at, :int64, null: false, default: 0

      t.column :word_count, :integer, null: false, default: 0
      t.column :chap_count, :integer, null: false, default: 0

      t.column :view_count, :integer, null: false, default: 0
      t.column :read_count, :integer, null: false, default: 0

      t.timestamps
    end
  end
end
