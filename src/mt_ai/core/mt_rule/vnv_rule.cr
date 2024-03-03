# require "./ai_node"

class MT::AiCore
  def split_vnv!(vv_node : MtNode, vv_body : Array(MtNode), vp_body : Array(MtNode)) : MtNode
    return vv_node unless vv_body.size == 3 && vv_body[1].zstr.in?("没", "不")

    vv_body[0].body = "hay"
    vp_body << vv_body[0]

    vv_body[1].body = "không"
    vp_body << vv_body[1]

    fix_vnv_head!(vv_body[2])
  end

  def split_vnv!(vv_node : MtNode, vv_body : MtPair, vp_body : Array(MtNode)) : MtNode
    return vv_node unless vv_body.tail.zstr[0].in?("没", "不")

    vv_body.tail.body = "hay không"
    vp_body << vv_body.tail
    fix_vnv_head!(vv_body.head)
  end

  def split_vnv!(vv_node : MtNode, vv_body : MtDefn | MtNode, vp_body : Array(MtNode)) : MtNode
    hd_zstr, md_zstr, tl_zstr = vv_node.zstr.partition(/没|不/)
    return vv_node if md_zstr.empty? || tl_zstr.empty?

    hd_body = MtDefn.auto_fix("hay", epos: :VV)
    hd_node = MtNode.new(zstr: hd_zstr, body: hd_body, epos: :VV, from: vv_node.from)

    hd_body = MtDefn.auto_fix("không", epos: :AD)
    tl_node = MtNode.new(zstr: md_zstr, body: hd_body, epos: :AD, from: hd_node.upto)

    vp_body << hd_node << tl_node

    case tl_zstr
    when "是" then vstr = "phải"
    when "会" then vstr = "biết"
    else          vstr = QtCore.verb_qt.tl_term(tl_zstr, :VV)
    end

    MtNode.new(zstr: tl_zstr, body: MtDefn.auto_fix(vstr), epos: :VV, from: tl_node.upto)
  end

  def fix_vnv_head!(head : MtNode) : MtNode
    case head.zstr
    when "是" then head.body = "phải"
    when "会" then head.body = "biết"
    end

    head
  end
end
