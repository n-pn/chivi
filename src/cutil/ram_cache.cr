class CV::RamCache(T)
  struct Entry(T)
    getter value : T
    getter stale : Time

    def initialize(@value, @stale)
    end
  end

  @cache : Hash(String, Entry(T))
  forward_missing_to @cache

  def initialize(@limit : Int32 = 512, @ttl : Time::Span = 3.minutes)
    @cache = new_cache
  end

  def get(key : String, stale = Time.utc) : T
    if entry = @cache[key]?
      return entry.value if entry.stale >= stale
    end

    @cache.clear if @cache.size >= @limit

    value = yield
    set(key, value)

    value
  end

  def set(key : String, value : T) : Entry(T)
    @cache[key] = Entry(T).new(value, Time.utc + @ttl)
  end

  private def new_cache
    Hash(String, Entry(T)).new(initial_capacity: @limit)
  end
end
