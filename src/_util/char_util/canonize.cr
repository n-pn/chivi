module CharUtil
  CANONICAL = {
    '\u00A0' => '　',
    '\u2002' => '　',
    '\u2003' => '　',
    '\u2004' => '　',
    '\u2007' => '　',
    '\u2008' => '　',
    '\u205F' => '　',
    '\u3000' => '　',

    '⟨' => '〈',
    '⟩' => '〉',
    '︱' => '｜',
    '︳' => '｜',
    '﹒' => '．',
    '﹐' => '，',
    '﹑' => '、',
    '､' => '、',
    '･' => '·',
    '‧' => '·',
    '•' => '·',
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
  @[AlwaysInline]
  def self.canonize(char : Char) : Char
    case
    when '!' <= char <= '~'
      (char.ord &+ 0xfee0).unsafe_chr
    when '！' <= char <= '～'
      char
    else
      CANONICAL.fetch(char, char)
    end
  end

  # :ditto:
  @[AlwaysInline]
  def self.canonize(str : String) : String
    String.build(str.bytesize) do |io|
      str.each_char { |char| io << canonize(char) }
    end
  end

  # convert input to fullwidth form + upcase
  # @[AlwaysInline]
  def self.upcase_canonize(char : Char) : Char
    case
    when 'a' <= char <= 'z'
      (char.ord &+ 0xfee0 &- 32).unsafe_chr
    when '!' <= char <= '~'
      (char.ord &+ 0xfee0).unsafe_chr
    when 'ａ' <= char <= 'ｚ'
      (char.ord &- 32).unsafe_chr
    when '！' <= char <= '～'
      char
    else
      CANONICAL.fetch(char, char)
    end
  end

  @[AlwaysInline]
  def self.upcase_canonize(str : String) : String
    String.build(str.bytesize) do |io|
      str.each_char { |char| io << upcase_canonize(char) }
    end
  end
end
