class RamCache(K, V)
  struct Entry(V)
    getter value : V
    getter stale : Time

    def initialize(@value, @stale)
    end
  end

  @cache : Hash(K, Entry(V))

  def initialize(@limit : Int32 = 512, @ttl : Time::Span = 5.minutes)
    @cache = Hash(K, Entry(V)).new(initial_capacity: @limit)
  end

  def has?(key : K) : Bool
    @cache.has_key?(key)
  end

  def get?(key : K, stale = Time.utc) : V | Nil
    return unless entry = @cache[key]?
    return entry.value if entry.stale >= stale
  end

  def get(key : K, stale = Time.utc, &) : V
    get?(key, stale).try { |x| return x }
    yield.tap { |x| set(key, x) }
  end

  def set(key : K, value : V, utime = Time.utc) : Entry(V)
    @cache.clear if @cache.size >= @limit
    @cache[key] = Entry(V).new(value, utime + @ttl)
  end

  delegate delete, to: @cache
  delegate clear, to: @cache
end
