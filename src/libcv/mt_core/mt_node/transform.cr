module MTL::Transform
  def update!(@val = @val, @tag = @tag, @dic = 1) : self
    self
  end

  def prepend!(other : self) : Nil
    @idx = other.idx
    @key = "#{other.key}#{@key}"
    @val = "#{other.val}#{@val}"
    @dic = other.dic if @dic < other.dic
  end

  def fuse_left!(left = "#{prev?(&.val)}", right = "", @dic = 6) : self
    return self unless prev = @prev

    @idx = prev.idx
    @key = "#{prev.key}#{@key}"
    @val = "#{left}#{@val}#{right}"

    fix_prev!(prev.prev?)
  end

  def fuse_right!(succ : self, @val = "#{@val} #{succ.val}", @dic = 6)
    @key = "#{@key}#{succ.key}"
    fix_succ!(succ.succ?)
  end

  def fuse_right!(val : String = "#{@val}#{succ?(&.val)}", dic = 6) : self
    return self unless succ = @succ
    fuse_right!(succ, val, dic)
  end

  def fuse_的!(succ : self, succ_succ : self, join = " ")
    @key = "#{@key}#{succ.key}#{succ_succ.key}"
    @val = "#{succ_succ.val}#{join}#{val}"
    @tag = succ_succ.tag
    @dic = succ_succ.dic if @dic < succ_succ.dic
    self.set_succ(succ_succ.succ?)
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
