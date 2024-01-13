# module MT::AiNode
#   def tl_whole!(dict : AiDict)
#     unless term = dict.get?(@zstr, @epos)
#       term = dict.get_alt?(@zstr) if !self.is_a?(M1Node) && @epos.can_use_alt?
#     end

#     self.set_term!(term) if term
#   end

#   def find_by_epos(epos : MtEpos)
#     z_each do |node|
#       return node if node.epos == epos
#       unless node.is_a?(M0Node)
#         found = node.find_by_epos(epos)
#         return found if found
#       end
#     end
#   end

#   def find_by_epos(*epos : MtEpos)
#     z_each do |node|
#       return node if node.epos.in?(*epos)

#       unless node.is_a?(M0Node)
#         found = node.find_by_epos(*epos)
#         return found if found
#       end
#     end
#   end

#   def is?(epos : MtEpos)
#     @epos == epos
#   end

#   def is?(&)
#     yield @epos
#   end

#   def attr?(attr : MtAttr)
#     @attr == MtAttr
#   end

#   def attr?(&)
#     yield @attr
#   end

#   def set_epos!(@epos : MtEpos) : Nil
#   end

#   def set_term!(term : ZvDefn) : Nil
#     @vstr = term.vstr
#     @attr |= term.attr
#     @dnum = term.dnum
#     @epos = term.fpos unless term.fpos.x?
#   end

#   def set_vstr!(@vstr : String, @dnum : DictEnum = :fixture_2) : Nil
#   end

#   def has_attr?(attr : MtAttr)
#     @attr.includes?(attr)
#   end

#   def set_attr!(@attr : MtAttr)
#   end

#   def add_attr!(attr : MtAttr)
#     @attr |= attr
#   end

#   def off_attr!(attr : MtAttr)
#     @attr &= ~attr
#   end

#   def same_attr?(other : self, attr : MtAttr)
#     self.attr & other.attr & attr != MtAttr::None
#   end

#   def to_json
#     JSON.build { |jb| to_json(jb) }
#   end

#   def to_json(io : IO) : Nil
#     JSON.build(io) { |jb| to_json(jb: jb) }
#   end

#   def to_json(jb : JSON::Builder) : Nil
#     jb.array do
#       jb.string @epos.to_s

#       if !@dnum.unknown_0? || self.is_a?(M0Node)
#         jb.string @zstr
#       else
#         jb.array { self.v_each(&.to_json(jb)) }
#       end

#       jb.number @_idx
#       jb.number @_idx &+ @zstr.size

#       jb.string @vstr
#       jb.string(@attr.none? ? "" : @attr.to_str)

#       jb.number @dnum.value
#     end
#   end
# end
