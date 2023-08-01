module CharUtil
  extend self

  # ### ⟨ => 〈
  # ### ⟩ => 〉
  #

  NORMALIZE = {
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

  def normalize(char : Char) : Char
    fullwidth?(char) ? to_halfwidth(char) : NORMALIZE.fetch(char, char)
  end

  def downcase_normalize(char : Char) : Char
    fullwidth?(char) ? to_halfwidth(char).downcase : NORMALIZE.fetch(char) { char.downcase }
  end

  CANONICAL = {
    ' ' => '　',
    '⟨' => '〈',
    '⟩' => '〉',
    '【' => '［',
    '】' => '］',
    '︱' => '｜',
    '︳' => '｜',
    '﹒' => '．',
    '﹐' => '，',
    '﹑' => '､',
    '、' => '､',
    '‧' => '･',
    '•' => '･',
    '‵' => '｀',
    'ˉ' => '－',
    '¯' => '－',
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
    '﹣' => '－',
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
  def canonicalize(char : Char, upcase : Bool = false) : Char
    case
    when 'a' <= char <= 'z' then to_fullwidth(upcase ? char - 32 : char)
    when '!' <= char <= '~' then to_fullwidth(char)
    else                         CANONICAL.fetch(char, char)
    end
  end

  # puts canonicalize('a', true)
  # puts canonicalize('a', false)
  # puts canonicalize('?', true)
  # puts canonicalize('$', true)

  # :ditto:
  def canonicalize(str : String, upcase : Bool = false) : String
    String.build do |io|
      str.each_char { |char| io << canonicalize(char, upcase: upcase) }
    end
  end

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

  def is_number?(char : Char)
    0x2F < char.ord < 0x3A
  end

  def is_letter?(char : Char)
    ('a' <= char <= 'z') || ('A' <= char <= 'Z')
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

  def is_hannum?(char : Char)
    HANNUM_CHARS.includes?(char)
  end

  def digit_to_int(char : Char)
    char.ord - 0x30
  end

  def hanzi_to_int(char : Char)
    HANNUM_VALUE[char]
  end
end
