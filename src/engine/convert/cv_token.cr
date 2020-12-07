require "../../shared/dict_utils"
require "../library/vp_dict"

require "./cv_entry"
require "./cv_group"

class Chivi::CvToken
  getter input : Array(Char)
  delegate size, to: @input

  def initialize(@input : Array(Char))
    @nodes = [CvEntry.new("", "")]
    @costs = [0.0]

    @input.each_with_index do |char, idx|
      norm = DictUtils.normalize(char).to_s
      # TODO: just check char.alphanumeric?
      dic = norm =~ /[_\p{L}\p{N}]/ ? 1 : 0

      @nodes << CvEntry.new(char.to_s, norm, dic)
      @costs << idx + 1.0
    end
  end

  def weighing(dict : VpDict, caret : Int32 = 0) : Nil
    dict.scan(@input, caret) do |term|
      next if term.vals.empty? || term.vals.first.empty?

      cost = @costs[caret] + term.worth
      jump = caret &+ term.key.size

      if cost > @costs[jump]
        @costs[jump] = cost
        @nodes[jump] = CvEntry.new(term.key, term.vals.first, 2, term.attr)
      end
    end
  end

  def to_group : CvGroup
    group = [] of CvEntry
    caret = size

    while caret > 0
      entry = @nodes[caret]
      caret -= entry.key.size

      if entry.dic == 1
        while caret > 0
          node = @nodes[caret]
          break if node.dic > 1
          break if node.dic == 0 && !node.special_mid_char?

          entry.combine!(node)
          caret -= node.key.size
        end

        if (last = group.last?) && last.special_end_char?
          last.combine!(entry)
          last.dic = 1
          next
        end
      elsif entry.dic == 0
        while caret > 0
          node = @nodes[caret]
          break if node.dic > 0 || entry.key[0] != node.key[0]

          entry.combine!(node)
          caret -= node.key.size
        end
      end

      group << entry
    end

    CvGroup.new(group.reverse)
  end
end
