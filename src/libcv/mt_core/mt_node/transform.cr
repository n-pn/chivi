module MTL::Transform
  def update!(@val = @val, @tag = @tag, @dic = 1) : self
    self
  end

  def prepend!(other : self) : Nil
    @key = "#{other.key}#{@key}"
    @val = "#{other.val}#{@val}"
    @dic = other.dic if @dic < other.dic
  end

  def fuse_left!(left = "#{@prev.try(&.val)}", right = "", @dic = 6) : self
    return self unless prev = @prev

    @key = "#{prev.key}#{@key}"
    @val = "#{left}#{@val}#{right}"

    self.prev = prev.prev
    self.prev.try(&.succ = self)

    self
  end

  def fuse_right!(@val : String = "#{@val}#{@succ.try(&.val)}", @dic = 6) : self
    return self unless succ = @succ

    @key = "#{@key}#{succ.key}"

    self.succ = succ.succ
    self.succ.try(&.prev = self)

    self
  end

  def fuse_的!(succ : self, succ_succ : self, join = " ")
    @key = "#{@key}#{succ.key}#{succ_succ.key}"
    @val = "#{succ_succ.val}#{join}#{val}"
    @tag = succ_succ.tag
    @dic = succ_succ.dic if @dic < succ_succ.dic
    self.set_succ(succ_succ.succ)
  end

  def replace!(@key, @val, @tag, @dic, succ)
    self.set_succ(succ)
  end

  def clear!
    @key = ""
    @val = ""
    @tag = PosTag::None
    @dic = 0
  end
end
