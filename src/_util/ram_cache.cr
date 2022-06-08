class CV::RamCache(K, V)
  struct Entry(V)
    getter value : V
    getter stale : Time

    def initialize(@value, @stale)
    end
  end

  @cache : Hash(K, Entry(V))

  def initialize(@limit : Int32 = 512, @ttl : Time::Span = 5.minutes)
    @cache = new_cache
  end

  def has?(key : K) : Bool
    @cache.has_key?(key)
  end

  def get? : V | Nil
    @cache[key]?
  end

  def get(key : K, stale = Time.utc) : V
    if entry = @cache[key]?
      return entry.value if entry.stale >= stale
    end

    @cache.clear if @cache.size >= @limit

    value = yield
    set(key, value)

    value
  end

  def set(key : K, value : V) : Entry(V)
    @cache[key] = Entry(V).new(value, Time.utc + @ttl)
  end

  def delete(key : K)
    @cache.delete(key)
  end

  def clear
    @cache.clear
  end

  private def new_cache
    Hash(K, Entry(V)).new(initial_capacity: @limit)
  end
end
