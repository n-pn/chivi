module CharUtil
  extend self

  #### ⟨ => 〈
  #### ⟩ => 〉

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

  def normalize(char : Char) : Char
    if (char.ord & 0xff00) == 0xff00
      (char.ord - 0xfee0).chr
    else
      NORMALIZE.fetch(char, char)
    end
  end

  def fullwidth?(char : Char)
    (char.ord & 0xff00) == 0xff00
  end

  def to_fullwidth(char : Char)
    (char.ord + 0xfee0).chr
  end

  def to_halfwidth(char : Char)
    (char.ord - 0xfee0).chr
  end

  def is_number?(char : Char)
    char.ord > 0x2F && char.ord < 0x3A
  end

  def is_letter?(char : Char)
    'a' <= char <= 'z' || 'A' <= char <= 'Z'
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
