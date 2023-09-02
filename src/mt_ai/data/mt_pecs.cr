require "../../_util/char_util"

@[Flags]
# word peculiarity
enum MT::MtPecs
  # reusable flags
  Void # ignore content
  Ncap # do not add cap

  Prep # put this in head position of a grammar structure
  Post # put this in tail position of a grammar structure

  Sufx # mark suffix words
  Dupl # mark word as reduplication

  # grammar/punctuation:

  Capr # grammar: capitalize the word after this
  Capx # grammar: capitalize the word after this instead capitalize this word

  Nwsl # grammar: do not add whitespace before this word
  Nwsr # grammar: do not add whitespace after this word
  Nwsx # grammar: do not add whitespace after this word if previous word do not need space after

  # noun characteristics

  Nadj # noun that acts like adjective in DNP construct
  Npos

  Nper # noun that referering to human being
  Nloc # noun that referering to placement/location/organization

  Nanm # animal
  Nwep # weapon

  # verb characteristics

  Vmod # modal verbs
  Vpsy # psychological verb

  Vint # intransitive verb
  Vdit # ditransitive verb

  @[AlwaysInline]
  def pad_space?(pad : Bool)
    pad && !(void? || nwsl?)
  end

  def to_str(io : IO, vstr : String, cap : Bool, pad : Bool)
    case
    when void?
      # do nothing
    when capx?
      io << vstr
    when !cap || ncap?
      io << vstr
      cap = capr?
    else
      vstr.each_char_with_index { |c, i| io << (i == 0 ? c.upcase : c) }
      cap = capr?
    end

    {cap, void? ? pad : !nwsr?}
  end

  ###

  @@known_chars = {} of Char => self

  @@known_chars = {
    ' ' => Capr | Nwsl | Nwsr,
    '　' => Capr | Nwsl | Nwsr,
    '！' => Capr | Nwsl,
    '＂' => Capx | Nwsl | Nwsr,
    '＃' => Capx | Nwsr,
    '＄' => Capx | Nwsr,
    '％' => Capx | Nwsl,
    '＆' => Capx | Nwsl | Nwsr,
    '＇' => Capx | Nwsl | Nwsr,
    '（' => Capx | Nwsr,
    '）' => Capx | Nwsl,
    '＊' => Capx | Nwsl | Nwsr,
    '＋' => Capx | Nwsl | Nwsr,
    ',' => Capx | Nwsl,
    '，' => Capx | Nwsl,
    '－' => Capx | Nwsl | Nwsr,
    '．' => Capr | Nwsl,
    '／' => Capx | Nwsl | Nwsr,
    '：' => Capr | Nwsl,
    '；' => Capx | Nwsl,
    '＜' => Capr | Nwsr,
    '＝' => Capx | Nwsl | Nwsr,
    '＞' => Capr | Nwsl,
    '？' => Capr | Nwsl,
    '＠' => Capx | Nwsr,
    '［' => Capx | Nwsr,
    '＼' => Capx | Nwsl | Nwsr,
    '］' => Capx | Nwsl,
    '＾' => Capx | Nwsl | Nwsr,
    '＿' => Capx | Nwsl | Nwsr,
    '｀' => Capx | Nwsr,
    '｛' => Capx | Nwsr,
    '｜' => Capx | Nwsl | Nwsr,
    '｝' => Capx | Nwsl,
    '～' => Capx | Nwsl,
    '｟' => Capx | Nwsr,
    '｠' => Capx | Nwsl,
    '｡' => Capr | Nwsl,
    '。' => Capr | Nwsl,
    '｢' => Capr | Nwsr,
    '｣' => Capx | Nwsl,
    '､' => Capx | Nwsl,
    '、' => Capx | Nwsl,
    '･' => Capx | Nwsl | Nwsr,
    # extra 1
    '〈' => Capr | Nwsr,
    '〉' => Capx | Nwsl,
    '《' => Capr | Nwsr,
    '》' => Capx | Nwsl,
    '‹' => Capr | Nwsr,
    '›' => Capx | Nwsl,
    # extra 2
    '“' => Capx | Nwsr,
    '‘' => Capx | Nwsr,
    '”' => Capx | Nwsl,
    '’' => Capx | Nwsl,
    '…' => Capx | Nwsl,
  }

  def self.parse(char : Char)
    char.alphanumeric? ? None : @@known_chars.fetch(char, Capx)
  end

  def self.parse_punct(zstr : String)
    pecs = @@known_chars.fetch(zstr[0], Capx)
    pecs | (@@known_chars[zstr[-1]]? || None)
  end

  def self.parse_list(input : String?) : self
    return None if input.nil? || input.blank?
    input.split(' ').reduce(None) { |memo, item| memo | parse(item) }
  end
end

# puts MT::MtPecs.parse_list("")
