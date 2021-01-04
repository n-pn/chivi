require "clear"

class Chivi::Migration::CreateBgenresTable
  include Clear::Migration

  def change(dir)
    create_table(:bgenres, id: :serial) do |t|
      t.column :zh_name, :string, unique: true, null: false
      t.column :vi_name, :string, null: false
      t.column :vslug, :string, unique: true, null: false

      t.timestamps
    end
  end
end
