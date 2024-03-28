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

  @[AlwaysInline]
  def alnum?(char : Char)
    char == '　' || ('０' <= char <= '９') || ('ａ' <= char <= 'ｚ') || ('Ａ' <= char <= 'Ｚ')
  end

  @[AlwaysInline]
  def ascii?(char : Char)
    '！' <= char <= '～'
  end

  @[AlwaysInline]
  def punct?(char : Char)
    char.in?('！', '？', '。', '…', '～')
  end

  @[AlwaysInline]
  def tokenize(input : String)
    tokenize(input.chars)
  end

  def tokenize(chars : Array(Char), upper = chars.size &- 1)
    best_sizes = Array(Int32).new(upper &+ 2, 1)
    best_costs = Array(Int16).new(upper &+ 2, 0)

    # table = chars.map_with_index do |char, i|
    #   best_terms << MtWseg.new(char.to_s)
    #   @dict.all_wsegs(chars, start: i)
    # end

    alnum = 0
    ascii = 0
    punct = 0

    upper.downto(0) do |i|
      best_cost = 0_i16
      best_size = 1

      @dict.each_wseg(chars, start: i) do |size, prio|
        cost = prio &+ best_costs[i &+ size]
        next if cost <= best_cost
        best_cost = cost
        best_size = size
      end

      char = chars.unsafe_fetch(i)

      if alnum?(char)
        alnum += 1
        ascii += 1
        punct = 0
      elsif ascii?(char)
        ascii += 1
        alnum = 0
        punct = 0
      elsif punct?(char)
        alnum = 0
        ascii = 0
        punct += 1
      else
        alnum = 0
        ascii = 0
        punct = 0
      end

      {ascii, alnum, punct}.each do |size|
        prio = DefnData.calc_prio(size, 1_i16) &- 1
        cost = prio &+ best_costs[i &+ size]
        next if cost <= best_cost
        best_cost = cost
        best_size = size
      end

      best_costs[i] = best_cost
      best_sizes[i] = best_size
    end

    # TODO: apply ner

    words = [] of String
    index = 0

    while index <= upper
      size = best_sizes[index]
      words << chars[index, size].join
      index += size
    end

    words
  end

  ###
end
