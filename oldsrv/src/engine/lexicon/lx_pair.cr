require "./lx_dict"

struct LxPair
  def initialize(@user : LxDict, @root : LxDict)
  end

  def upsert(key : String, val : String = "", mode = :new_first, sync = false)
    @user.set(key, val, mode: mode)
    @root.set(key, val, mode: mode) if sync
  end

  def pair
    {@user, @root}
  end

  def search(term : String)
    vals = [] of String
    time : Time? = nil

    if item = @user.find(term)
      vals.concat(item.vals)
      time ||= item.updated_at
    end

    if item = @root.find(term)
      vals.concat(item.vals).uniq!
      time ||= item.updated_at
    end

    {vals, time.try(&.to_unix_ms)}
  end

  def scan(chars : Array(Char), offset : Int32 = 0)
    items = {} of Int32 => LxItem

    @root.scan(chars, offset).each do |item|
      items[item.key.size] = item
    end

    @user.scan(chars, offset).each do |item|
      items[item.key.size] = item
    end

    items
  end
end
