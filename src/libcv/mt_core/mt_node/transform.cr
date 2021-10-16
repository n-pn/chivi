module CV::MTL::Transform
  def heal!(@val : String = self.val, @tag : PosTag = self.tag)
    self
  end

  def fold_many!(*nodes : self)
    key_io = String::Builder.new(@key)
    nodes.each { |x| key_io << x.key }
    @key = key_io.to_s
    fix_succ!(nodes[-1].succ?)
  end
end
