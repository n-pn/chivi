def rearrange!(dict : AiDict) : Nil
  case @epos
  when .vpt?
    @rhsn.set_vstr!(vstr: "nổi") if @rhsn.zstr == "住"
  when .vnv?
    fix_vnv! if @lhsn.zstr == @rhsn.zstr
  end
end

def fix_vnv_3!
  AiRule.fix_vnv_lhs!(@lhsn)

  case @midn.zstr
  when "没", "不"
    @midn.set_vstr!("không")
    @rhsn.set_vstr!("hay")
    @midn, @rhsn = @rhsn, @midn
  when "一"
    @midn.set_vstr!("thử")
  end
end

def fix_vnv_2!
  AiRule.fix_vnv_lhs!(@lhsn)

  case @rhsn.zstr[0]
  when '没', '不'
    @rhsn.set_vstr!("hay không")
  when '一'
    @rhsn.set_vstr!("thử #{@lhsn.vstr}")
  end
end

def fix_vnv_lhs!(node : AiNode) : Nil
  case node.zstr
  when "是" then node.set_vstr!("phải")
  when "会" then node.set_vstr!("biết")
  end
end
