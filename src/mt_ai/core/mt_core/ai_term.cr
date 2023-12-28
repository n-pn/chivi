require "../ai_dict"

class MT::AiTerm
  property epos = MtEpos::X
  property attr = MtAttr::None

  property orig : String | Array(RawCon) = ""
  property tran : String | Array(AiTerm) = ""

  property dnum = DictEnum::Unknown_0
  property from = 0
  property upto = 0

  def initialize(@epos, @attr, @orig, @tran, @dnum, @from, @upto)
  end

  def zstr
    @orig.try { |x| x.is_a?(String) ? x : x.join(&.zstr) }
  end

  # def find_by_epos(epos : MtEpos)
  #   z_each do |node|
  #     return node if node.epos == epos
  #     unless node.is_a?(M0Node)
  #       found = node.find_by_epos(epos)
  #       return found if found
  #     end
  #   end
  # end

  # def find_by_epos(*epos : MtEpos)
  #   z_each do |node|
  #     return node if node.epos.in?(*epos)

  #     unless node.is_a?(M0Node)
  #       found = node.find_by_epos(*epos)
  #       return found if found
  #     end
  #   end
  # end

  # def is?(epos : MtEpos)
  #   @epos == epos
  # end

  # def is?(&)
  #   yield @epos
  # end

  # def attr?(attr : MtAttr)
  #   @attr == MtAttr
  # end

  # def attr?(&)
  #   yield @attr
  # end

  # def set_epos!(@epos : MtEpos) : Nil
  # end

  # def set_term!(term : MtTerm) : Nil
  #   @vstr = term.vstr
  #   @attr |= term.attr
  #   @dnum = term.dnum
  #   @epos = term.fpos unless term.fpos.x?
  # end

  # def set_vstr!(@vstr : String, @dnum : DictEnum = :fixture_2) : Nil
  # end

  # def has_attr?(attr : MtAttr)
  #   @attr.includes?(attr)
  # end

  # def set_attr!(@attr : MtAttr)
  # end

  # def add_attr!(attr : MtAttr)
  #   @attr |= attr
  # end

  # def off_attr!(attr : MtAttr)
  #   @attr &= ~attr
  # end

  # def same_attr?(other : self, attr : MtAttr)
  #   self.attr & other.attr & attr != MtAttr::None
  # end

  # ###

  COLORS = {:green, :yellow, :blue, :red, :cyan, :magenta, :light_gray}

  SINGLE_LINES = {
    "VCD", "VRD", "VNV", "VPT", "VCP",
    "VAS", "DVP", "QP", "DNP", "DP",
    "CLP",
  }

  def inspect(io : IO, deep = 1)
    io << '('.colorize.dark_gray
    io << @epos.to_s.colorize.bold
    io << ' ' << @attr unless @attr.none?
    # io << ':' << @_idx

    case tran = @tran
    when String
      io << ' ' << self.zstr.colorize.dark_gray
      io << ' ' << tran.colorize(COLORS[@dnum.value % 10]) unless @dnum.unknown_0?
    when Array
      on_line = @epos.to_s.in?(SINGLE_LINES)

      tran.each do |node|
        if on_line
          io << ' '
        else
          io << '\n'
          deep.times { io << "  " }
        end
        node.inspect(io: io, deep: deep &+ 1)
      end
    end

    io << ')'.colorize.dark_gray
  end

  # ###

  def to_txt(cap : Bool = true, und : Bool = true)
    String.build { |io| to_txt(io, cap: cap, und: und) }
  end

  def to_txt(io : IO, cap : Bool, und : Bool)
    # pp [self]
    case tran = @tran
    in String
      io << ' ' unless @attr.undent?(und: und)
      @attr.render_vstr(io, tran, cap: cap, und: und)
    in Array
      tran.each { |node| cap, und = node.to_txt(io, cap: cap, und: und) }
      {cap, und}
    end
  end

  def to_json
    JSON.build { |jb| to_json(jb) }
  end

  def to_json(io : IO) : Nil
    JSON.build(io) { |jb| to_json(jb: jb) }
  end

  def to_json(jb : JSON::Builder) : Nil
    jb.array do
      jb.string @epos.to_s

      case tran = @tran
      in String
        jb.string tran
      in Array
        jb.array { tran.each(&.to_json(jb)) }
      end

      jb.number @from
      jb.number @upto
      jb.string(@attr.none? ? "" : @attr.to_str)
      jb.number @dnum.value
    end
  end
end
