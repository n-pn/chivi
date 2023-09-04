require "../../_util/char_util"

@[Flags]
# word peculiarity
enum MT::MtPecs
  # reusable flags
  Void # ignore content
  Ncap # do not add cap

  At_h # put this in head position of a grammar structure
  At_t # put this in tail position of a grammar structure

  Prfx # mark prefix words
  Sufx # mark suffix words

  # grammar/punctuation:

  Capn # grammar: capitalize the word after this
  Capx # grammar: capitalize the word after this instead capitalize this word

  Padb # grammar: do not add whitespace before this word
  Padn # grammar: do not add whitespace after this word

  # noun characteristics

  Nplr # plural noun
  Nuct # uncountable

  Ndes # descriptive noun
  Npos # possestive noun

  Nper # noun that referering to human being
  Nloc # noun that referering to placement/location/organization

  # Nhrf = Sufx | Nper
  # Nspc = Sufx | Nloc

  # pronoun

  Pn_p # personal personal
  Pn_d # demonstrative pronoun
  Pn_i # interrogative pronoun

  # verb characteristics

  Vmod # modal verbs
  Vpsy # psychological verb

  Vint # intransitive verb
  Vdit # ditransitive verb

  # adverb

  Dneg # negative
  Ddeg # degree
  Dtim # time
  Dsco # scope
  Dmoo # mood
  Dfre # frequency
  Dcor # correl
  Dman # manner

  # complement

  # Cres # Bổ ngữ kết quả
  # Cdeg # Bổ ngữ mức độ
  # Cdir # Bổ ngữ xu hướng
  # Cpot # Bổ ngữ khả năng
  # Csta # Bổ ngữ tình trạng
  # Cqua # Bổ ngữ số lượng
  # Ctim # Bổ ngữ thời gian

  # quantifier

  # Qtim
  # Qver
  # Qnou
  # Qmas
  # Qwei
  # Qdis
  # Qmon

  ###

  @[AlwaysInline]
  def pad_space?(pad : Bool)
    pad && !(void? || padb?)
  end

  def to_str(io : IO, vstr : String, cap : Bool, pad : Bool)
    case
    when void?
      # do nothing
    when capx?
      io << vstr
    when !cap || ncap?
      io << vstr
      cap = capn?
    else
      vstr.each_char_with_index { |c, i| io << (i == 0 ? c.upcase : c) }
      cap = capn?
    end

    {cap, void? ? pad : !padn?}
  end

  ###

  @@known_chars = {} of Char => self

  @@known_chars = {
    ' ' => Capn | Padb | Padn,
    '　' => Capn | Padb | Padn,
    '！' => Capn | Padb,
    '＂' => Capx | Padb | Padn,
    '＃' => Capx | Padn,
    '＄' => Capx | Padn,
    '％' => Capx | Padb,
    '＆' => Capx | Padb | Padn,
    '＇' => Capx | Padb | Padn,
    '（' => Capx | Padn,
    '）' => Capx | Padb,
    '＊' => Capx | Padb | Padn,
    '＋' => Capx | Padb | Padn,
    ',' => Capx | Padb,
    '，' => Capx | Padb,
    '－' => Capx | Padb | Padn,
    '．' => Capn | Padb,
    '／' => Capx | Padb | Padn,
    '：' => Capn | Padb,
    '；' => Capx | Padb,
    '＜' => Capn | Padn,
    '＝' => Capx | Padb | Padn,
    '＞' => Capn | Padb,
    '？' => Capn | Padb,
    '＠' => Capx | Padn,
    '［' => Capx | Padn,
    '＼' => Capx | Padb | Padn,
    '］' => Capx | Padb,
    '＾' => Capx | Padb | Padn,
    '＿' => Capx | Padb | Padn,
    '｀' => Capx | Padn,
    '｛' => Capx | Padn,
    '｜' => Capx | Padb | Padn,
    '｝' => Capx | Padb,
    '～' => Capx | Padb,
    '｟' => Capx | Padn,
    '｠' => Capx | Padb,
    '｡' => Capn | Padb,
    '。' => Capn | Padb,
    '｢' => Capn | Padn,
    '｣' => Capx | Padb,
    '､' => Capx | Padb,
    '、' => Capx | Padb,
    '･' => Capx | Padb | Padn,
    # extra 1
    '〈' => Capn | Padn,
    '〉' => Capx | Padb,
    '《' => Capn | Padn,
    '》' => Capx | Padb,
    '‹' => Capn | Padn,
    '›' => Capx | Padb,
    # extra 2
    '“' => Capx | Padn,
    '‘' => Capx | Padn,
    '”' => Capx | Padb,
    '’' => Capx | Padb,
    '…' => Capx | Padb,
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
