require "./mt_dict"

class MT::WsCore
  CACHE = {} of String => self

  class_getter word_hv : self { load!("word_hv") }
  class_getter name_hv : self { load!("name_hv") }

  def self.load!(pdict : String) : self
    CACHE[pdict] ||= new(MtDict.for_qt(pdict))
  end

  def initialize(@dict : MtDict)
  end

  def parse!(input : String)
    chars = input.chars

    best_terms = [] of MtWseg
    best_costs = Array(Int16).new(chars.size + 1, 0)

    table = chars.map_with_index do |char, i|
      best_terms << MtWseg.new(char.to_s)
      @dict.all_wsegs(chars, start: i)
    end

    (chars.size - 1).downto(0) do |i|
      terms = table[i]
      next if terms.empty?

      best_cost = 0_i16
      best_term = best_terms[i]

      if best_ner_term = get_best_ner_term(table, i, terms)
        terms << best_ner_term
      end

      terms.each do |term|
        cost = term.prio + best_costs[i + term.size]

        if cost > best_cost
          best_cost = cost
          best_term = term
        end
      end

      best_costs[i] = best_cost
      best_terms[i] = best_term
    end

    # TODO: apply ner

    tokens = [] of MtWseg
    cursor = 0

    while cursor < chars.size
      best = best_terms[cursor]
      tokens << best
      cursor &+= best.zstr.size
    end

    tokens
  end

  private def get_best_ner_term(table, index, terms)
    best_term = nil
    ner_terms = terms.reject(&.bner.none?)

    while term = ner_terms.shift?
      next unless tails = table[index + term.size]?

      tails.each do |tail|
        new_bner = term.bner & tail.iner
        next if new_bner.none?

        new_term = MtWseg.new(
          zstr: "#{term.zstr}#{tail.zstr}",
          bner: new_bner,
          iner: term.iner,
          oner: tail.oner
        )

        ner_terms << new_term
        next if (new_bner & ~tail.oner).none?

        next if best_term && (best_term.size > new_term.size || best_term.bner > new_bner)
        best_term = new_term
      end
    end

    best_term
  end
end
