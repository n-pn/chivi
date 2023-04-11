require "./ent_term"

class MT::NerNode
  getter term : EntTerm

  getter len : Int32
  getter sum : Int32

  getter? temp : Bool
  getter succ : NerNode? = nil

  def self.new(left : self, right : self)
    new(
      term: left.term,
      len: left.len,
      sum: left.sum &+ right.sum,
      temp: true,
      succ: right
    )
  end

  def initialize(@term, @len, @sum = len, @temp = false, @succ = nil)
  end

  def get_value(mark : EntMark)
    String.build do |io|
      node = self

      loop do
        io << node.term.vstr
        break unless node = node.succ
      end
    end
  end

  @[AlwaysInline]
  def bner?(mark : EntMark)
    @term.bner.includes?(mark)
  end

  @[AlwaysInline]
  def iner?(mark : EntMark)
    @term.iner.includes?(mark)
  end

  @[AlwaysInline]
  def ener?(mark : EntMark)
    @term.ener.includes?(mark)
  end

  @[AlwaysInline]
  def sner?(mark : EntMark)
    @term.sner.includes?(mark)
  end
end
