require "../../_util/char_util"

@[Flags]
# word peculiarity
enum AI::VpPecs
  # reusable flags

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

  Nper # noun that referering to human being
  Nloc # noun that referering to placement/location/organization

  Nanm # animal
  Nwep # weapon

  # verb characteristics

  Vmod # modal verbs
  Vpsy # psychological verb

  Vint # intransitive verb
  Vdit # ditransitive verb

  Void = Capx | Nwsx

  ###

  @@known_chars = {} of Char => self

  @@known_chars = {
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
    '｢' => Capr | Nwsr,
    '｣' => Capx | Nwsl,
    '､' => Capx | Nwsl,
    '･' => Capx | Nwsl | Nwsr,

    '〈' => Capr | Nwsr,
    '〉' => Capx | Nwsl,
    '《' => Capr | Nwsr,
    '》' => Capx | Nwsl,
    '‹' => Capr | Nwsr,
    '›' => Capx | Nwsl,

    '“' => Capx | Nwsr,
    '‘' => Capx | Nwsr,
    '”' => Capx | Nwsl,
    '’' => Capx | Nwsl,
    '…' => Capx | Nwsl,
  }

  def self.parse_punct(zstr : String)
    pecs = @@known_chars.fetch(zstr[0], Capx)
    pecs | (@@known_chars[zstr[-1]]? || None)
  end

  def self.parse(char : Char)
    char.alphanumeric? ? None : @@known_chars.fetch(char, Capx)
  end

  def self.parse_list(input : String?) : self
    pecs = None
    return pecs if !input || input.blank?

    input.split(' ') { |item| pecs |= self.parse(item) }
    pecs
  end
end

# puts AI::VpPecs.parse_punct("．")
