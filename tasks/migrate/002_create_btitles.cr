require "clear"

class Chivi::Migration::CreateBtitles
  include Clear::Migration

  def change(dir)
    create_table(:btitles) do |t|
      t.column "zh_name", "citext", unique: true, null: false
      t.column "zh_name_tsv", "string", array: true, index: "gin", null: false

      t.column "vi_name", "citext", index: true, null: false
      t.column "vi_name_tsv", "string", array: true, index: "gin", null: false

      t.timestamps
    end
  end
end
