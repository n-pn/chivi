module CharUtil
  extend self

  # ### ⟨ => 〈
  # ### ⟩ => 〉
  #

  NORMALIZE = {
    '\u00A0' => ' ',
    '\u2002' => ' ',
    '\u2003' => ' ',
    '\u2004' => ' ',
    '\u2007' => ' ',
    '\u2008' => ' ',
    '\u205F' => ' ',

    '〈' => '⟨',
    '〉' => '⟩',
    '《' => '⟨',
    '》' => '⟩',
    '　' => ' ',
    'ˉ' => '¯',
    '‥' => '¨',
    '‧' => '·',
    '•' => '·',
    '‵' => '`',
    '。' => '.',
    '﹒' => '.',
    '﹐' => ',',
    '﹑' => ',',
    '、' => ',',
    '︰' => ':',
    '∶' => ':',
    '﹔' => ';',
    '﹕' => ':',
    '﹖' => '?',
    '﹗' => '!',
    '﹙' => '(',
    '﹚' => ')',
    '﹛' => '{',
    '﹜' => '}',
    '【' => '[',
    '﹝' => '[',
    '】' => ']',
    '﹞' => ']',
    '﹟' => '#',
    '﹠' => '&',
    '﹡' => '*',
    '﹢' => '+',
    '﹣' => '-',
    '﹤' => '<',
    '﹥' => '>',
    '﹦' => '=',
    '﹩' => '$',
    '﹪' => '%',
    '﹫' => '@',
    '≒' => '≈',
    '≦' => '≤',
    '≧' => '≥',
    '︱' => '|',
    '︳' => '|',
    '︿' => '∧',
    '﹀' => '∨',
    '╴' => '_',
    '「' => '“',
    '」' => '”',
    '『' => '‘',
    '』' => '’',
    '｟' => '(',
    '｠' => ')',
  }

  def normalize(str : String) : String
    String.build do |io|
      str.each_char { |char| io << normalize(char) }
    end
  end

  @[AlwaysInline]
  def normalize(char : Char) : Char
    fullwidth?(char) ? to_halfwidth(char) : NORMALIZE.fetch(char, char)
  end

  @[AlwaysInline]
  def downcase_normalize(char : Char) : Char
    fullwidth?(char) ? to_halfwidth(char).downcase : NORMALIZE.fetch(char) { char.downcase }
  end

  CANONICAL = {
    '\u00A0' => '　',
    '\u2002' => '　',
    '\u2003' => '　',
    '\u2004' => '　',
    '\u2007' => '　',
    '\u2008' => '　',
    '\u205F' => '　',

    ' ' => '　',
    '⟨' => '〈',
    '⟩' => '〉',
    '︱' => '｜',
    '︳' => '｜',
    '﹒' => '．',
    '﹐' => '，',
    '﹑' => '、',
    '､' => '、',
    '･' => '‧',
    '·' => '‧',
    '•' => '‧',
    '‵' => '｀',
    '﹤' => '＜',
    '﹥' => '＞',
    '╴' => '＿',
    '︰' => '：',
    '∶' => '：',
    '﹕' => '：',
    '﹔' => '；',
    '﹖' => '？',
    '﹗' => '！',
    '﹙' => '（',
    '﹚' => '）',
    '﹛' => '｛',
    '﹜' => '｝',
    '【' => '［',
    '﹝' => '［',
    '】' => '］',
    '﹞' => '］',
    '﹟' => '＃',
    '﹠' => '＆',
    '﹡' => '＊',
    '﹢' => '＋',
    '—' => '－',
    '﹣' => '－',
    'ˉ' => '－',
    '¯' => '－',
    '「' => '“',
    '」' => '”',
    '『' => '‘',
    '』' => '’',
    '∧' => '︿',
    '∨' => '﹀',
    '﹦' => '＝',
    '﹩' => '＄',
    '﹪' => '％',
    '﹫' => '＠',
    '¨' => '‥',

    '｟' => '（',
    '｠' => '）',

    '≒' => '≈',
    '≦' => '≤',
    '≧' => '≥',

  }

  # convert input to fullwidth form
  def to_canon(char : Char, upcase : Bool = false) : Char
    case
    when '!' <= char <= '~' then to_fullwidth(char)
    when 'a' <= char <= 'z' then to_fullwidth(upcase ? char - 32 : char)
    when 'ａ' <= char <= 'ｚ' then upcase ? char - 32 : char
    else                         CANONICAL.fetch(char, char)
    end
  end

  # puts to_canon('a', true)
  # puts to_canon('a', false)
  # puts to_canon('?', true)
  # puts to_canon('$', true)

  # :ditto:
  def to_canon(str : String, upcase : Bool = false) : String
    String.build do |io|
      str.each_char { |char| io << to_canon(char, upcase: upcase) }
    end
  end

  ####

  @[AlwaysInline]
  def fullwidth?(char : Char)
    '！' <= char <= '～'
  end

  @[AlwaysInline]
  def halfwidth?(char : Char)
    '!' <= char <= '~'
  end

  @[AlwaysInline]
  def to_fullwidth(char : Char)
    (char.ord &+ 0xfee0).chr
  end

  @[AlwaysInline]
  def to_halfwidth(char : Char)
    (char.ord &- 0xfee0).chr
  end

  def to_halfwidth(str : String)
    String.build do |io|
      str.each_char do |char|
        io << to_halfwidth(char)
      end
    end
  end

  def hw_digit?(char : Char)
    '0' <= char <= '9'
  end

  def hw_alpha?(char : Char)
    ('a' <= char <= 'z') || ('A' <= char <= 'Z')
  end

  def hw_alnum?(char : Char)
    ('0' <= char <= '9') || ('a' <= char <= 'z') || ('A' <= char <= 'Z')
  end

  def fw_digit?(char : Char)
    '０' <= char <= '９'
  end

  def fw_alpha?(char : Char)
    ('ａ' <= char <= 'ｚ') || ('Ａ' <= char <= 'Ｚ')
  end

  def fw_alnum?(char : Char)
    ('０' <= char <= '９') || ('ａ' <= char <= 'ｚ') || ('Ａ' <= char <= 'Ｚ')
  end

  HANNUM_CHARS = {
    '零', '〇', '一', '两', '二', '三', '四',
    '五', '六', '七', '八', '九', '十', '百',
    '千', '万', '亿', '兆',
  }

  HANNUM_VALUE = {
    '零' => 0, '两' => 2,
    '〇' => 0, '一' => 1,
    '二' => 2, '三' => 3,
    '四' => 4, '五' => 5,
    '六' => 6, '七' => 7,
    '八' => 8, '九' => 9,
    '十' => 10, '百' => 100,
    '千' => 1000, '万' => 10_000,
    '亿' => 100_000_000, '兆' => 1_000_000_000_000,
  }

  def hannum?(char : Char)
    HANNUM_CHARS.includes?(char)
  end

  def digit_to_int(char : Char)
    char.ord - 0x30
  end

  def hanzi_to_int(char : Char)
    HANNUM_VALUE[char]
  end
end
