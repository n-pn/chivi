require "./char_util/*"

module CharUtil
  ####

  @[AlwaysInline]
  def self.fullwidth?(char : Char)
    '！' <= char <= '～'
  end

  @[AlwaysInline]
  def self.halfwidth?(char : Char)
    '!' <= char <= '~'
  end

  @[AlwaysInline]
  def self.to_fullwidth(char : Char)
    (char.ord &+ 0xfee0).chr
  end

  @[AlwaysInline]
  def self.to_halfwidth(char : Char)
    (char.ord &- 0xfee0).chr
  end

  def self.to_halfwidth(str : String)
    String.build do |io|
      str.each_char do |char|
        io << to_halfwidth(char)
      end
    end
  end

  def self.hw_digit?(char : Char)
    '0' <= char <= '9'
  end

  def self.hw_alpha?(char : Char)
    ('a' <= char <= 'z') || ('A' <= char <= 'Z')
  end

  def self.hw_alnum?(char : Char)
    ('0' <= char <= '9') || ('a' <= char <= 'z') || ('A' <= char <= 'Z')
  end

  def self.fw_digit?(char : Char)
    '０' <= char <= '９'
  end

  def self.fw_alpha?(char : Char)
    ('ａ' <= char <= 'ｚ') || ('Ａ' <= char <= 'Ｚ')
  end

  def self.fw_alnum?(char : Char)
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

  def self.hannum?(char : Char)
    HANNUM_CHARS.includes?(char)
  end

  def self.digit_to_int(char : Char)
    char.ord - 0x30
  end

  def self.hanzi_to_int(char : Char)
    HANNUM_VALUE[char]
  end
end
