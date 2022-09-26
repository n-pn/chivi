require "./_generic"

module MtlV2::MTL
  module Numeral
  end

  class NumberWord < BaseWord
    include Numeral

    def to_int
      0_i64
    end

    def noun_prefix?
      true
    end
  end

  class NdigitWord < NumberWord
    def to_int
      @val.to_i64
    end

    NDIGIT_RE = /^[0-9０-９]+$/

    def self.matches?(key : String)
      key.matches?(NDIGIT_RE)
    end
  end

  class NhanziWord < NumberWord
    def to_int
      QtranUtil.to_int(@val)
    end

    NHANZI_RE = /^[零〇一二两三四五六七八九十百千万亿兆]+$/

    def self.matches?(key : String)
      key.matches?(NHANZI_RE)
    end
  end

  QTTIMES = QtranUtil.read_tsv("etc/cvmtl/qttimes.tsv")
  QTVERBS = QtranUtil.read_tsv("etc/cvmtl/qtverbs.tsv")
  QTNOUNS = QtranUtil.read_tsv("etc/cvmtl/qtverbs.tsv")

  @[Flags]
  enum QuantiAttr
    ForTime
    ForVerb
    ForNoun

    def self.from(key : String, dirty = false)
      key = clear_key(key) if dirty

      flag = None

      flag |= ForTime if QTTIMES.has_key?(key)
      flag |= ForVerb if QTVERBS.has_key?(key)
      flag |= ForNoun if QTNOUNS.has_key?(key)

      flag
    end

    def self.clear_key(key : String)
      key.sub(/[零〇一二两三四五六七八九十百千万亿兆多每]+/, "")
    end
  end

  class QuantiWord < BaseWord
    getter attr : QuantiAttr = :for_noun
    forward_missing_to @attr

    def initialize(term : V2Term, pos : Int32 = 0)
      super(term)
      @attr = QuantiAttr.from(term.key)
    end

    def initialize(@key = "", @val = @key, @tab = 0, @idx = 0)
    end

    def as_quanti!
      self
    end
  end

  class NquantWord < BaseWord
    getter attr : QuantiAttr = :for_noun
    forward_missing_to @attr

    def initialize(term : V2Term, pos : Int32 = 0)
      super(term, pos)
      @attr = QuantiAttr.from(term.key, dirty: true)
    end

    def as_quanti!
      self
    end
  end

  ###
end
