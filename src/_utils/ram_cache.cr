class CV::RamCache(T)
  @main : Hash(String, T)
  @cold : Hash(String, T)

  def initialize(@limit : Int32 = 512)
    @main = new_cache
    @cold = new_cache
  end

  def get(key : String)
    unless item = @main[key]?
      @main[key] = item = @cold[key]? || yield

      if @main.size >= @limit
        @cold = @main
        @main = new_cache
      end
    end

    item
  end

  def delete(key : String)
    @main.delete(key)
    @cold.delete(key)
  end

  private def new_cache
    Hash(String, T).new(initial_capacity: @limit + 1)
  end
end
