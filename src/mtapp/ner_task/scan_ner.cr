require "./cvner/*"
require "./core/ent_term"

module MT::BasicNer
  HANNUM_CHARS = {
    '一', '两',
    '二', '三',
    '四', '五',
    '六', '七',
    '八', '九',
    '十', '百',
    '千', '万',
    '亿', '兆',
  }

  def self.scan_all(input : Array(Char), idx = 0)
    upper = input.size

    res = Array(MtTerm?).new(size: upper) { nil }

    while idx < upper
      case input.unsafe_fetch(idx)
      when .ascii_letter?
        new_idx, tag, val = ScanString.scan_one(input, idx)
      when .ascii_number?
        new_idx, tag, val = ScanNumber.scan_one(input, idx)
      when .in?(HANNUM_CHARS)
        new_idx, tag, val = NumlitNER.detect(input, idx)
      when '几'
        idx += 1
        next_char = input.unsafe_fetch(idx)
        next unless next_char.in?(HANNUM_CHARS)

        new_idx, tag, val = NumlitNER.detect(input, idx, "mấy ")
        idx -= 1
      else
        idx += 1
        next
      end

      size = new_idx &- idx
      val ||= input[idx...new_idx].join

      cost = MtTerm.cost(size, prio: 2)
      term = MtTerm.new(val, dic: 1, size: size, ptag: tag, cost: cost)
      res[idx] = term.tap(&.idx = idx)
      idx = new_idx
    end

    res
  end
end