require "./models/_utils"
require "./models/mt_dict"
require "./mt_data"
require "./mt_core/*"

class MT::Engine
  def initialize(dname : String, uname : String? = nil)
    @dicts = MtDict.new(dname, uname)
  end

  def cv_plain(input : String, cap_first = true, start = 0) : MtData
    data = tokenize(input.chars, start: start)
    data.fix_grammar!
    data.apply_cap!(cap: cap_first)
    data
  end

  def tokenize(input : Array(Char), start = 0) : MtData
    nodes = [BaseTerm.new("", idx: start)]
    costs = [0]

    input.each_with_index do |char, idx|
      nodes << BaseTerm.new(char, idx: idx &+ start)
      costs << idx &+ 1
    end

    ner_idx = 0

    input.size.times do |idx|
      base_cost = costs.unsafe_fetch(idx)

      if idx >= ner_idx && (ner_term = Core.ner_recog(input, idx))
        ner_idx = idx &+ ner_term.key.size

        size = ner_term.key.size
        jump = idx &+ size
        cost = base_cost + Utils.seg_weight(size, 1_i8)

        if cost > costs[jump]
          ner_term.offset_idx!(start)
          nodes[jump] = ner_term
          costs[jump] = cost
        end
      end

      @dicts.scan(input, start) do |term, key_size, dict_id|
        cost = base_cost &+ term.seg
        jump = idx &+ key_size

        if cost >= costs[jump]
          nodes[jump] = BaseTerm.new(term, dict_id)
          costs[jump] = cost
        end
      end
    end

    extract_result(nodes)
  end

  def extract_result(nodes : Array(BaseTerm))
    idx = nodes.size &- 1
    res = MtData.new

    while idx > 0
      cur = nodes.unsafe_fetch(idx)
      idx -= cur.key.size
      res.add_node(cur)
    end

    res
  end
end
