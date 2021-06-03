@[Flags]
enum CV::VpAttr
  Noun
  Verb
  Adje # adjective

  Pronoun # pronoun

  Number1 # latin numbers (0-9+)
  Number2 # chinese number literals

  def self.parse(input : String)
    attr = new(0)

    attr |= Noun if input.includes?('N')
    attr |= Verb if input.includes?('V')
    attr |= Adje if input.includes?('A')

    attr
  end

  def self.parse_prio(input : String)
    case input[0]?
    when 'H' then 2
    when 'L' then 0
    else          1
    end
  end

  def self.pronoun?(hanzi : String)
    case hanzi
    when "我", "你", "您", "他", "她", "它",
         "我们", "咱们", "你们", "您们", "他们", "她们", "它们",
         "朕", "人家", "老子"
      true
    else
      false
    end
  end
end

# puts CV::VpAttr.parse("NV")
