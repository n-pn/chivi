require "clear"

class Chivi::Migrate::SetupDB
  include Clear::Migration

  def change(dir)
    dir.up do
      execute "CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;"
      execute "CREATE EXTENSION IF NOT EXISTS intarray WITH SCHEMA public;"
    end

    dir.down do
      execute "DROP EXTENSION IF EXISTS citext;"
      execute "DROP EXTENSION IF EXISTS intarray;"
    end
  end
end
