require "./_shared"

# word peculiarity
# sort by most common types
@[Flags]
enum MT::MtAttr : Int32
  # nominal characteristics

  Ndes # descriptive noun
  Ntmp # mark temporal noun

  Nper # noun that referering to human being
  Nloc # noun that referering to placement/location/organization
  Norg # group of human?

  # shared characteristics

  At_h # put this in head position of a grammar structure
  At_t # put this in tail position of a grammar structure

  Prfx # mark prefix words
  Sufx # mark suffix words

  # grammar/punctuation:

  Hide # ignore content
  Asis # do not add cap

  Capn # grammar: capitalize the word after this
  Capx # grammar: capitalize the word after this instead capitalize this word

  Undb # grammar: do not add whitespace before this word
  Undn # grammar: do not add whitespace after this word

  # verbal characteristics

  Vpst # positive verb

  Vmod # modal verbs
  Vpsy # psychological verb

  Vint # intransitive verb
  Vdit # ditransitive verb

  # pronoun types (unused)

  Pn_d # demonstrative pronoun
  Pn_i # interrogative pronoun

  # adverb types (unused)

  # Dneg # negative
  # Ddeg # degree
  # Dtim # time
  # Dsco # scope
  # Dmoo # mood
  # Dfre # frequency
  # Dcor # correl
  # Dman # manner

  @[AlwaysInline]
  def turn_off(attr : self)
    self & ~attr
  end

  def any?(other : self)
    (self & other) != None
  end

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
    '‧' => Capx | Undb | Undn,
    '·' => Capx | Undb | Undn,
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

  ###

  def self.from_ctb(cpos : String, ctag : String)
    case
    when cpos == "NT"  then Ntmp
    when cpos != "NP"  then None
    when ctag == "PN"  then Nper
    when ctag == "TMP" then Ntmp
    else                    None
    end
  end

  def self.from_ctb(epos : MtEpos, ctag : String, zstr : String = "")
    case
    when epos.nt?      then Ntmp
    when epos.em?      then MtAttr[Asis, Capx]
    when epos.pu?      then parse_punct(zstr)
    when !epos.np?     then None
    when ctag == "PN"  then Nper
    when ctag == "TMP" then Ntmp
    else                    None
    end
  end

  def self.from_rs(rs : ::DB::ResultSet)
    new(rs.read(Int32))
  end

  def self.to_db(epos : self)
    epos.value
  end
end

# puts MT::MtAttr.parse_list("")
