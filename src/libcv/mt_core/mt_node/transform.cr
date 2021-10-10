module CV::MTL::Transform
  def fold_left!(left : Nil)
    self
  end

  def fold_left!(left : self, val : String = "#{left.val} #{@val}", tag : PosTag = @tag, dic : Int32 = 6) : self
    left.tag = tag
    left.fold!(self, val, dic)
  end

  def fold!(succ : self, @val : String = "#{@val} #{succ.val}", @dic = 6) : self
    @key = "#{@key}#{succ.key}"
    fix_succ!(succ.succ?)
  end

  def fold_many!(*nodes : self)
    key_io = String::Builder.new(@key)
    nodes.each { |x| key_io << x.key }
    @key = key_io.to_s
    fix_succ!(nodes[-1].succ?)
  end

  def fold!(val : String = "#{@val} #{succ.val}", dic = 6) : self
    fold!(succ, val, dic)
  end

  def heal!(@val : String = self.val, @tag : PosTag = self.tag)
    self
  end
end
