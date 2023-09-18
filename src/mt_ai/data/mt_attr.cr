require "../../_util/char_util"
require "../../_util/text_util"

@[Flags]
# word peculiarity
enum MT::MtAttr
  # reusable flags
  Hide # ignore content
  Asis # do not add cap

  At_h # put this in head position of a grammar structure
  At_t # put this in tail position of a grammar structure

  Prfx # mark prefix words
  Sufx # mark suffix words

  # grammar/punctuation:

  Capn # grammar: capitalize the word after this
  Capx # grammar: capitalize the word after this instead capitalize this word

  Undb # grammar: do not add whitespace before this word
  Undn # grammar: do not add whitespace after this word

  # noun characteristics

  Nper # noun that referering to human being
  Nloc # noun that referering to placement/location/organization
  Norg # group of human?

  Ndes # descriptive noun
  Ntmp # mark temporal noun

  # Nhrf = Sufx | Nper
  # Nspc = Sufx | Nloc

  # pronoun

  Pn_d # demonstrative pronoun
  Pn_i # interrogative pronoun

  # verb characteristics

  Vint # intransitive verb
  Vdit # ditransitive verb

  Vmod # modal verbs
  Vpsy # psychological verb

  # adverb

  # Dneg # negative
  # Ddeg # degree
  # Dtim # time
  # Dsco # scope
  # Dmoo # mood
  # Dfre # frequency
  # Dcor # correl
  # Dman # manner

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
  def to_str
    self.none? ? "" : self.to_s.gsub(" | ", ' ')
  end

  @[AlwaysInline]
  def undent?(und : Bool)
    und || self.hide? || self.undb?
  end

  def render_vstr(io : IO, vstr : String, cap : Bool, und : Bool)
    case
    when self.hide?
      # do nothing
    when self.capx?
      io << vstr
    when self.asis? || !cap
      io << vstr
      cap = self.capn?
    else
      vstr.each_char do |char|
        io << (cap && char.alphanumeric? ? char.upcase : char)
        cap = false
      end
      cap = self.capn?
    end

    {cap, self.hide? ? und : self.undn?}
  end

  def fix_vstr(vstr : String, cap : Bool) : {String, Bool}
    case
    when self.hide?         then {"", cap || self.capn?}
    when self.capx?         then {vstr, cap}
    when self.asis? || !cap then {vstr, self.capn?}
    else                         {TextUtil.capitalize(vstr), self.capn?}
    end
  end

  ###

  @@known_chars = {} of Char => self

  @@known_chars = {
    ' ' => Capn | Undb | Undn,
    '　' => Capn | Undb | Undn,
    '！' => Capn | Undb,
    '＂' => Capx | Undb | Undn,
    '＃' => Capx | Undn,
    '＄' => Capx | Undn,
    '％' => Capx | Undb,
    '＆' => Capx | Undb | Undn,
    '＇' => Capx | Undb | Undn,
    '（' => Capx | Undn,
    '）' => Capx | Undb,
    '＊' => Capx | Undb | Undn,
    '＋' => Capx | Undb | Undn,
    ',' => Capx | Undb,
    '，' => Capx | Undb,
    '－' => Capx | Undb | Undn,
    '．' => Capn | Undb,
    '／' => Capx | Undb | Undn,
    '：' => Capn | Undb,
    '；' => Capx | Undb,
    '＜' => Capn | Undn,
    '＝' => Capx | Undb | Undn,
    '＞' => Capn | Undb,
    '？' => Capn | Undb,
    '＠' => Capx | Undn,
    '［' => Capx | Undn,
    '＼' => Capx | Undb | Undn,
    '］' => Capx | Undb,
    '＾' => Capx | Undb | Undn,
    '＿' => Capx | Undb | Undn,
    '｀' => Capx | Undn,
    '｛' => Capx | Undn,
    '｜' => Capx | Undb | Undn,
    '｝' => Capx | Undb,
    '～' => Capx | Undb,
    '｟' => Capx | Undn,
    '｠' => Capx | Undb,
    '｡' => Capn | Undb,
    '。' => Capn | Undb,
    '｢' => Capn | Undn,
    '｣' => Capx | Undb,
    '､' => Capx | Undb,
    '、' => Capx | Undb,
    '･' => Capx | Undb | Undn,
    # extra 1
    '〈' => Capn | Undn,
    '〉' => Capx | Undb,
    '《' => Capn | Undn,
    '》' => Capx | Undb,
    '‹' => Capn | Undn,
    '›' => Capx | Undb,
    # extra 2
    '“' => Capx | Undn,
    '‘' => Capx | Undn,
    '”' => Capx | Undb,
    '’' => Capx | Undb,
    '…' => Capx | Undb,
  }

  def self.parse(char : Char)
    char.alphanumeric? ? None : @@known_chars.fetch(char, Capx)
  end

  def self.parse_punct(zstr : String)
    attr = @@known_chars.fetch(zstr[0], Capx)
    attr | (@@known_chars[zstr[-1]]? || None)
  end

  def self.parse_list(input : String?) : self
    return None if input.nil? || input.blank?
    input.split(' ').reduce(None) { |memo, item| memo | parse(item) rescue memo }
  end

  def self.parse_list!(input : String?) : self
    return None if input.nil? || input.blank?
    input.split(' ').reduce(None) { |memo, item| memo | parse(item) }
  end
end

# puts MT::MtAttr.parse_list("")
