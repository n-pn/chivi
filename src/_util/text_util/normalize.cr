module CV::TextUtil
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

  extend self

  # Convert chinese punctuations to english punctuations
  # and full width characters to ascii characters
  def normalize(input : String) : String
    normalize(input.chars).join
  end

  # :ditto:
  def normalize(input : Array(Char)) : Array(Char)
    input.map { |char| normalize(char) }
  end

  # :ditto:
  def normalize(char : Char) : Char
    if (char.ord & 0xff00) == 0xff00
      (char.ord - 0xfee0).chr
    else
      NORMALIZE.fetch(char, char)
    end
  end
end
