@[Flags]
enum SP::MtProp
  CapAfter

  NoSpaceL
  NoSpaceR

  StrPart
  UrlPart
  IntPart

  Content

  @@known = {
    ' '  => NoSpaceL | NoSpaceR | CapAfter,
    '.'  => CapAfter | NoSpaceL | UrlPart,
    '!'  => CapAfter | NoSpaceL | UrlPart,
    '?'  => CapAfter | NoSpaceL | UrlPart,
    '⟨'  => CapAfter | NoSpaceR,
    '<'  => CapAfter | NoSpaceR,
    '‹'  => CapAfter | NoSpaceR,
    '⟩'  => CapAfter | NoSpaceL,
    '>'  => CapAfter | NoSpaceL,
    '›'  => CapAfter | NoSpaceL,
    '“'  => NoSpaceR,
    '‘'  => NoSpaceR,
    '['  => NoSpaceR,
    '{'  => NoSpaceR,
    '('  => NoSpaceR,
    '”'  => NoSpaceL,
    '’'  => NoSpaceL,
    ']'  => NoSpaceL,
    '}'  => NoSpaceL,
    ')'  => NoSpaceL,
    ','  => NoSpaceL,
    ';'  => NoSpaceL,
    '…'  => NoSpaceL,
    '\'' => NoSpaceL | NoSpaceR,
    '"'  => NoSpaceL | NoSpaceR,
    '·'  => NoSpaceL | NoSpaceR,
    ':'  => NoSpaceL | UrlPart,
    '%'  => NoSpaceL | UrlPart,
    '~'  => NoSpaceL | UrlPart,
    '#'  => NoSpaceR | UrlPart,
    '$'  => NoSpaceR | UrlPart,
    '@'  => NoSpaceR | UrlPart,
    '+'  => NoSpaceL | NoSpaceR | UrlPart,
    '-'  => NoSpaceL | NoSpaceR | UrlPart,
    '='  => NoSpaceL | NoSpaceR | UrlPart,
    '/'  => NoSpaceL | NoSpaceR | UrlPart,
    '&'  => NoSpaceL | NoSpaceR | UrlPart,
    '*'  => NoSpaceL | NoSpaceR | UrlPart,
  }

  def self.map(char : Char)
    case char
    when 'a'..'z', 'A'..'Z'
      StrPart | UrlPart
    when '0'..'9', '_'
      IntPart | StrPart | UrlPart
    else
      @@known[char]? || Content
    end
  end
end
