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

  QTTIMES = QtranUtil.read_tsv("etc/cvmtl/qttimes.tsv")
  QTVERBS = QtranUtil.read_tsv("etc/cvmtl/qtverbs.tsv")
  QTNOUNS = QtranUtil.read_tsv("etc/cvmtl/qtverbs.tsv")

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
    getter kind : QuantiKind = :noun

    def initialize(term : V2Term, pos : Int32 = 0)
      super(term)
      @kind = QuantiKind.from(term.key)
    end
  end

  class NquantWord < BaseWord
    getter kind : QuantiKind = :noun

    def initialize(term : V2Term, pos : Int32 = 0)
      super(term, pos)
      @kind = QuantiKind.from(term.key, dirty: true)
    end
  end

  ###

  def self.number_from_term(term : V2Term, pos : Int32 = 0)
    return NquantWord.new(term, pos: pos) if term.tags[0] == "mq"

    case
    when NdigitWord.matches?(term.key) then NdigitWord.new(term, pos: pos)
    when NhanziWord.matches?(term.key) then NhanziWord.new(term, pos: pos)
    else                                    NumberWord.new(term, pos: pos)
    end
  end

  def self.quanti_from_term(term : V2Term, pos : Int32 = 0)
    # TODO: add QuantiVerb, QuantiTime...
    QuantiWord.new(term, pos: pos)
  end
end
