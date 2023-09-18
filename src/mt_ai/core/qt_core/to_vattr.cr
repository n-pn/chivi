require "./qt_data"

struct MT::HvietToVarr
  def initialize(@input : QtData)
  end

  def to_json(jb : JSON::Builder)
    jb.array do
      @input.each do |node|
        if node.zstr.size == 1
          jb.array { jb.string node.vstr; jb.string node.attr.to_str }
        else
          split_vstr(node) do |vstr, attr|
            jb.array { jb.string vstr; jb.string attr.to_str }
          end
        end
      end
    end
  end

  private def split_vstr(node : QtNode)
    undb = MtAttr::Undb
    undn = MtAttr::Undn

    zlen = node.zstr.size
    vstr = node.vstr
    attr = MtAttr.new(node.attr)
    zidx = 0

    if vstr.size == zlen
      vstr.each_char do |char|
        zidx &+= 1

        case zidx
        when 1    then yield char, attr
        when zlen then yield char, attr & undb
        else           yield char, undb
        end
      end
    else
      vstr.split(' ') do |word|
        zidx += 1

        case zidx
        when 1    then yield word, attr & ~undn
        when zlen then yield word, attr & ~undb
        else           yield word, MtAttr::None
        end
      end

      (zlen &- zidx).times { yield "", MtAttr::Hide }
    end
  end
end
