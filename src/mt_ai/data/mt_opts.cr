require "../../_util/char_util"

@[Flags]
enum AI::MtOpts
  Hidden # do not render content
  Frozen # do not add cap

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
    ':'  => AddCapAfter | NoSpaceBefore,
    '⟨'  => AddCapAfter | NoSpaceAfter,
    '<'  => AddCapAfter | NoSpaceAfter,
    '‹'  => AddCapAfter | NoSpaceAfter,
    '⟩'  => NoSpaceBefore,
    '>'  => NoSpaceBefore,
    '›'  => NoSpaceBefore,
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
    self.hidden? || self.no_space_before? || prev.no_space_after? ||
      (self.no_space_passive? && prev.no_space_before?)
  end

  @[AlwaysInline]
  private def merge_add_cap_after(prev : self)
    prev.add_cap_after? ? self | AddCapAfter : self
  end

  def apply_cap(io : IO, str : String, prev : self) : self
    case
    when self.hidden?
      flag = self.merge_add_cap_after(prev)
      prev.no_space_after? ? flag | NoSpaceAfter : flag
    when self.add_cap_passive? # usually for punctuation or special tokens
      io << str
      self.merge_add_cap_after(prev)
    when self.frozen? || !prev.add_cap_after?
      io << str
      self
    else # do not do anything if no capitalization needed
      str.each_char_with_index { |c, i| io << (i == 0 ? c.upcase : c) }
      self
    end
  end

  def self.detect(char : Char)
    char.alphanumeric? ? None : @@known_chars.fetch(char, AddCapPassive)
  end

  def self.detect(zstr : String)
    zstr.each_char.reduce(None) { |acc, char| acc | detect(char) }
  end

  def self.auto_detect(zstr : String)
    return None if zstr.empty?
    # return Hidden if zstr == "⛶"

    flag = zstr.matches?(/[\p{Han}\p{L}\p{N}]/) ? None : AddCapPassive

    flag_of_first_char = detect(zstr[0])
    flag |= NoSpaceBefore if flag_of_first_char.no_space_before?

    flag_of_last_char = detect(zstr[-1])
    flag |= NoSpaceAfter if flag_of_last_char.no_space_after?
    flag |= AddCapAfter if flag_of_last_char.add_cap_after?

    flag
  end

  def self.for_punctuation(vstr : String)
    flag = detect(vstr[0])
    return flag if vstr.size == 1

    tail = detect(vstr[-1])
    flag |= NoSpaceAfter if tail.no_space_after?
    flag |= AddCapAfter if tail.add_cap_after?

    flag
  end
end
