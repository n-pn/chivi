@[Flags]
enum MT::FmtFlag : UInt8
  AddCapAfter   # cap after
  AddCapPassive # cap after only if cap flag is raised

  NoSpaceAfter   # do not add whitespace after
  NoSpaceBefore  # do not add whitespace before
  NoSpacePassive # do not add whitespace after if previous node prevent adding whitespace before

  Initial = AddCapAfter | NoSpaceBefore
  Passive = AddCapPassive | NoSpacePassive

  @[AlwaysInline]
  def add_space?(prev : self)
    self.no_space_before? || prev.no_space_after? ||
      (self.no_space_passive? && prev.no_space_before?)
  end

  def apply_cap(io : IO, str : String, prev : self) : self
    if self.add_cap_passive? # usually for punctuation or special tokens
      io << str
      prev.add_cap_after? ? self | AddCapAfter : self
    elsif prev.add_cap_after? # for normal tokens, apply upper case for the first letter
      str.each_char_with_index { |c, i| io << (i == 0 ? c.upcase : c) }
      self
    else # do not do anything if no capitalization needed
      io << str
      self
    end
  end

  def self.from(flags : Enumerable(String))
    output = None

    flags.each do |flag|
      case flag
      when "ac_a" then output |= AddCapAfter
      when "ac_p" then output |= AddCapPassive
      when "ns_a" then output |= NoSpaceAfter
      when "ns_b" then output |= NoSpaceBefore
      when "ns_p" then output |= NoSpacePassive
      else             raise "Unknown fmt flag #{flag}"
      end
    end

    output
  end
end
