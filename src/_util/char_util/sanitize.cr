module CharUtil
  SANITIZE = {
    '\u00A0' => ' ',
    '\u2002' => ' ',
    '\u2003' => ' ',
    '\u2004' => ' ',
    '\u2007' => ' ',
    '\u2008' => ' ',
    '\u205F' => ' ',
    '\u3000' => ' ',

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

  # convert fullwidth to half width, keep punctuation
  def self.fast_sanitize(input : String)
    String.build(input.bytesize) do |io|
      input.each_char do |char|
        case
        when ('０' <= char <= '９') || ('ａ' <= char <= 'ｚ') || ('Ａ' <= char <= 'Ｚ')
          io << (char.ord &- 0xfee0).unsafe_chr
        when char.ord < 128 || '！' <= char <= '～'
          io << char
        else
          io << SANITIZE.fetch(char, char)
        end
      end
    end
  end

  @[AlwaysInline]
  def self.trim_sanitize(input : String) : String
    fast_sanitize(input).strip
  end

  # TODO:
  def self.full_sanitize(input : String)
    String.build(input.bytesize) do |io|
      chars = input.chars

      input.each_char do |char|
        case
        # when '.'
        #   io << (ascii ? char : '。')
        when '!' <= char <= '~'
          io << char
        when '！' <= char <= '～'
          io << to_halfwidth(char)
        else
          io << SANITIZE.fetch(char, char)
        end
      end
    end
  end
end
