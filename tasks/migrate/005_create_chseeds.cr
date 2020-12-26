require "clear"

class Chivi::Migration::CreateChseedsTable
  include Clear::Migration

  def change(dir)
    create_table(:chseeds, id: :serial) do |t|
      t.column :nvinfo_id, :integer, index: true

      t.column :seed, :string, null: false
      t.column :sbid, :string, null: false

      t.column :_order, :integer, null: false, default: 0
      t.column :status, :integer, null: false, default: 0

      t.column :update_tz, :int64, null: false, default: 0
      t.column :access_tz, :int64, null: false, default: 0

      t.column :word_count, :integer, null: false, default: 0
      t.column :chap_count, :integer, null: false, default: 0

      t.column :view_count, :integer, null: false, default: 0
      t.column :read_count, :integer, null: false, default: 0

      t.timestamps

      t.index [:seed, :sbid], unique: true
    end
  end
end
