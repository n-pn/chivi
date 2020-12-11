require "clear"

class Chivi::Migration::CreateBgenres
  include Clear::Migration

  def change(dir)
    create_table(:bgenres) do |t|
      t.column "zh_name", "string", unique: true, null: false
      t.column "vi_name", "string", unique: true, null: false
      t.column "vi_slug", "string", unique: true, null: false

      t.timestamps
    end
  end
end
