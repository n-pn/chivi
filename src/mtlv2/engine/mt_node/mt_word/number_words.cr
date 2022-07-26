require "../mt_base/*"

module MtlV2::MTL
  module Numeral
  end

  class NumberWord < BaseWord
    include Numeral

    def to_int
      0_i64
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

  QTTIMES = QtranUtil.load_tsv("etc/cvmtl/qttimes.tsv")
  QTVERBS = QtranUtil.load_tsv("etc/cvmtl/qtverbs.tsv")
  QTNOUNS = QtranUtil.load_tsv("etc/cvmtl/qtverbs.tsv")

  @[Flags]
  enum QuantiKind
    Time
    Verb
    Noun

    def self.from(key : String, dirty = false)
      key = clear_key(key) if dirty

      flag = None

      flag |= Time if QTTIMES.has_key?(key)
      flag |= Verb if QTVERBS.has_key?(key)
      flag |= Noun if QTNOUNS.has_key?(key)

      flag
    end

    def self.clear_key(key : String)
      key.sub(/[零〇一二两三四五六七八九十百千万亿兆多每]+/, "")
    end
  end

  class QuantiWord < BaseWord
    getter kind : QuantiKind

    def initialize(term : V2Term, @kind : QuantiKind = QuantiKind.from(term.key))
      super(term)
    end
  end

  class NquantWord < BaseWord
    getter kind : QuantiKind

    def initialize(term : V2Term, @kind : QuantiKind = QuantiKind.from(term.key, dirty: true))
      super(term)
    end
  end
end
