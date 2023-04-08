@[Flags]
enum MT::FmtFlag : UInt8
  AddCapAfter   # cap after
  AddCapPassive # cap after only if cap flag is raised

  NoSpaceAfter   # do not add whitespace after
  NoSpaceBefore  # do not add whitespace before
  NoSpacePassive # do not add whitespace after if previous node prevent adding whitespace before

  Nospace = NoSpaceBefore | NoSpaceAfter
  Initial = AddCapAfter | Nospace
  Passive = AddCapPassive | NoSpacePassive

  # TODO: remove this line
  @@known_chars = {} of Char => self

  @@known_chars = {
    ' '  => AddCapAfter | NoSpaceBefore | NoSpaceAfter,
    '.'  => AddCapAfter | NoSpaceBefore,
    '!'  => AddCapAfter | NoSpaceBefore,
    '?'  => AddCapAfter | NoSpaceBefore,
    '⟨'  => AddCapAfter | NoSpaceAfter,
    '<'  => AddCapAfter | NoSpaceAfter,
    '‹'  => AddCapAfter | NoSpaceAfter,
    '⟩'  => AddCapAfter | NoSpaceBefore,
    '>'  => AddCapAfter | NoSpaceBefore,
    '›'  => AddCapAfter | NoSpaceBefore,
    '“'  => AddCapPassive | NoSpaceAfter,
    '‘'  => AddCapPassive | NoSpaceAfter,
    '['  => AddCapPassive | NoSpaceAfter,
    '{'  => AddCapPassive | NoSpaceAfter,
    '('  => AddCapPassive | NoSpaceAfter,
    '”'  => AddCapPassive | NoSpaceBefore,
    '’'  => AddCapPassive | NoSpaceBefore,
    ']'  => AddCapPassive | NoSpaceBefore,
    '}'  => AddCapPassive | NoSpaceBefore,
    ')'  => AddCapPassive | NoSpaceBefore,
    ','  => AddCapPassive | NoSpaceBefore,
    ';'  => AddCapPassive | NoSpaceBefore,
    '…'  => AddCapPassive | NoSpaceBefore,
    '\'' => AddCapPassive | NoSpaceBefore | NoSpaceAfter,
    '"'  => AddCapPassive | NoSpaceBefore | NoSpaceAfter,
    '·'  => AddCapPassive | NoSpaceBefore | NoSpaceAfter,
    ':'  => AddCapPassive | NoSpaceBefore,
    '%'  => AddCapPassive | NoSpaceBefore,
    '~'  => AddCapPassive | NoSpaceBefore,
    '#'  => AddCapPassive | NoSpaceAfter,
    '$'  => AddCapPassive | NoSpaceAfter,
    '@'  => AddCapPassive | NoSpaceAfter,
    '+'  => AddCapPassive | NoSpaceBefore | NoSpaceAfter,
    '-'  => AddCapPassive | NoSpaceBefore | NoSpaceAfter,
    '='  => AddCapPassive | NoSpaceBefore | NoSpaceAfter,
    '/'  => AddCapPassive | NoSpaceBefore | NoSpaceAfter,
    '&'  => AddCapPassive | NoSpaceBefore | NoSpaceAfter,
    '*'  => AddCapPassive | NoSpaceBefore | NoSpaceAfter,
  }

  @[AlwaysInline]
  def no_space?(prev : self)
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

  def self.detect(chr : Char)
    chr.alphanumeric? ? None : @@known_chars.fetch(chr, AddCapPassive)
  end

  def self.detect(inp : String)
    inp.each_char.reduce(None) { |acc, chr| acc | detect(chr) }
  end

  def self.parse(flags : Enumerable(String))
    flags.reduce(None) do |acc, flag|
      case flag
      when "ac_a" then acc | AddCapAfter
      when "ac_p" then acc | AddCapPassive
      when "ns_a" then acc | NoSpaceAfter
      when "ns_b" then acc | NoSpaceBefore
      when "ns_p" then acc | NoSpacePassive
      else             raise "Unknown fmt flag #{flag}"
      end
    end
  end
end
