module MtlV2::AST
  NUMLAT_RE = /^[0-9０-９]+$/
  NUMHAN_RE = /^[零〇一二两三四五六七八九十百千万亿兆]+$/

  def self.number_from_term(term : V2Term)
    return nquant_from_term(term) if term.attr == "mq"
    case term.key
    when .matches?(NUMLAT_RE) then Ndigit.new(term)
    when .matches?(NUMHAN_RE) then Nhanzi.new(term)
    else                           Number.new(term)
    end
  end

  def self.quanti_from_term(term : V2Term)
    case term.key
    when "个月", "分钟"
  end

  class Numeral < BaseNode
  end

  class Number < Numeral
    def to_int
      0
    end
  end

  class Ndigit < Number
    def to_int
      @val.to_i64
    end
  end

  class Nhanzi < Number
    def to_int
      res = 0_i64
      mod = 1_i64
      acc = 0_i64

      @val.chars.reverse_each do |char|
        int = HAN_VAL[char]? || 0

        case char
        when '兆', '亿', '万', '千', '百', '十'
          res += acc
          mod = int if mod < int
          acc = int
        else
          res += int * mod
          mod *= 10
          acc = 0
        end
      end

      res + acc
    end

    HAN_VAL = {
      '零' => 0,
      '〇' => 0,
      '一' => 1,
      '两' => 2,
      '二' => 2,
      '三' => 3,
      '四' => 4,
      '五' => 5,
      '六' => 6,
      '七' => 7,
      '八' => 8,
      '九' => 9,
      '十' => 10,
      '百' => 100,
      '千' => 1000,
      '万' => 10_000,
      '亿' => 100_000_000,
      '兆' => 1_000_000_000_000,
    }
  end

  class Nmixed < Number
  end

  class Quanti < Numeral
  end

  class Qtnoun < Quanti
  end

  class Qttime < Quanti
    MAP_VAL = {
      "个月" =>	"tháng"
"小时" =>	"giờ"
"分钟" =>	"phút"
"秒" =>	"giây"
"秒钟" =>	"giây"
"日" =>	"ngày"
"月" =>	"tháng"
"年" =>	"năm"
"岁" =>	"tuổi"
"周" =>	"tuần"
"席" =>	"bữa"
"晚" =>	"đêm"
"刻" =>	"khắc"
"载" =>	"năm"
    }
  end

  class Qtverb < Quanti
  end

  class Nquant < Numeral
  end

  class Nqnoun < Nquant
  end

  class Nqtime < Nquant
  end

  class Nqverb < Nquant
  end
end
