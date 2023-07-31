require "./_base"

class AI::NpNode
  include MtNode

  getter noun : MtNode | Array(MtNode)
  getter pref = [] of MtNode
  getter suff = [] of MtNode

  def initialize(input : Array(MtNode), @ptag, @attr, @_idx)
    @noun = input # reludant

    while fnode = input.shift?
      # pp fnode

      if input.empty?
        @noun = fnode
        break
      end

      case fnode.ptag
      when "DNP"
        fnode.attr.includes?("HEAD") ? pref.push(fnode) : suff.unshift(fnode)
      when "QP"
        pref.push(fnode)
      else
        input.unshift(fnode)
        @noun = input
        break
      end
    end
  end

  def each(&)
    @pref.each { |node| yield node }

    case noun = @noun
    in MtNode        then yield noun
    in Array(MtNode) then noun.each { |node| yield node }
    end

    suff.each { |node| yield node }
  end

  def last
    @noun.last
  end
end
