require "sqlite3"

module DB3
  extend self

  def open_db(db_path : String, &)
    connection_url = "sqlite3:#{db_path}?journal_mode=WAL&synchronous=normal"
    DB.open(connection_url) { |db| yield db }
  end

  def open_tx(db_path : String, &) : Nil
    open_db(db_path) do |db|
      db.exec "begin"
      yield db
      db.exec "commit"
    rescue ex
      db.close
      raise ex
    end
  end

  def init_db(db_path : String, init_sql : String)
    open_tx(db_path) do |db|
      init_sql.split(";", remove_empty: true) do |sql|
        db.exec(sql) unless sql.blank?
      end
    end
  end
end
