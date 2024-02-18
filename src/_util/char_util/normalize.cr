module CharUtil
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
    '　'      => ' ',

    '〈' => '⟨',
    '〉' => '⟩',
    '《' => '⟨',
    '》' => '⟩',
    'ˉ' => '¯',
    '‥' => '¨',
    '‧' => '·',
    '•' => '·',
    '‵' => '`',
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

  @[AlwaysInline]
  def self.normalize(str : String) : String
    String.build do |io|
      str.each_char { |char| io << normalize(char) }
    end
  end

  @[AlwaysInline]
  def self.normalize(char : Char) : Char
    case
    when '！' <= char <= '～'
      (char.ord &- 0xfee0).chr
    when '!' <= char <= '~'
      char
    else
      NORMALIZE.fetch(char, char)
    end
  end

  @[AlwaysInline]
  def self.downcase_normalize(char : Char) : Char
    case
    when 'Ａ' <= char <= 'Ｚ'
      (char.ord &- 0xfee0 &+ 32).unsafe_chr
    when '！' <= char <= '～'
      (char.ord &- 0xfee0).unsafe_chr
    when 'A' <= char <= 'Z'
      (char.ord &+ 32).unsafe_chr
    when '!' <= char <= '~'
      char
    else
      NORMALIZE.fetch(char, char)
    end
  end
end
