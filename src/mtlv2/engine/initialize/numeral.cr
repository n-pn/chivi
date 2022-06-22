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
    case
    when Qttime.has_key?(term.key) then Qttime.new(term)
    when Qtverb.has_key?(term.key) then Qtverb.new(term)
    when Qtnoun.has_key?(term.key) then Qttime.new(term)
    else                                Quanti.new(term)
    end
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
      "个月" => "tháng",
      "小时" => "giờ",
      "分钟" => "phút",
      "秒"  => "giây",
      "秒钟" => "giây",
      "日"  => "ngày",
      "月"  => "tháng",
      "年"  => "năm",
      "岁"  => "tuổi",
      "周"  => "tuần",
      "席"  => "bữa",
      "晚"  => "đêm",
      "刻"  => "khắc",
      "载"  => "năm",
    }

    def self.has_key?(key : String)
      MAP_VAL.has_key?(key)
    end
  end

  class Qtverb < Quanti
    MAP_VAL = {
      "次"  => "lần", # ǀlượtǀchuyến
      "回"  => "hồi",
      "遍"  => "lượt",
      "趟"  => "chuyến", # ǀlầnǀhàngǀdãy
      "下"  => "phát",
      "顿"  => "chầu", # ǀhồiǀtrận
      "番"  => "phen", # ǀloạiǀdạngǀhồiǀlần
      "阵"  => "trận",
      "会"  => "lúc",
      "下儿" => "phát",
      "会儿" => "lát",
    }

    def self.has_key?(key : String)
      MAP_VAL.has_key?(key)
    end
  end

  class Qtnoun < Quanti
    MAP_VAL = {
      "钧"  => "quân",
      "袭"  => "bộ",
      "丈"  => "trượng",
      "招"  => "chiêu",
      "笔"  => "bút",
      "家"  => "nhà",
      "度"  => "độ",
      "处"  => "chỗ",
      "瓶"  => "chai",
      "石"  => "thạch",
      "丝"  => "tia",
      "抬"  => "đài",
      "里"  => "dặm",
      "米"  => "mét",
      "帮"  => "đám", # ǀbọnǀđànǀlũǀnhómǀtốpǀbang
      "道"  => "đạo", # ǀđườngǀnétǀvạch
      "股"  => "cỗ",
      "更"  => "canh",
      "重"  => "tầng",
      "分"  => "phần",
      "只"  => "con",
      "本"  => "quyển",
      "种"  => "loại",
      "间"  => "gian",
      "声"  => "tiếng",
      "代"  => "đời", # ǀthờiǀnhàǀlớp
      "圈"  => "vòng",
      "场"  => "trận", # ǀbữa
      "轮"  => "vòng", # ǀvầngǀvànhǀlượt
      "步"  => "bước",
      "盘"  => "khay",
      "茬"  => "vụ", # ǀlứaǀđợt
      "餐"  => "bữa",
      "架"  => "khung",
      "期"  => "kỳ",
      "层"  => "tầng",
      "门"  => "môn",
      "转"  => "vòng",
      "架次" => "lượt chiếc",
      "场次" => "lượt diễn",
      "人次" => "lượt người",
      "站"  => "trạm",
      "拨"  => "tốp",
      "张"  => "trương",
      "线"  => "tuyến",
      "口"  => "miệng",
      "笼"  => "lồng",
      "剂"  => "liều",
      "桩"  => "cọc",
      "堂"  => "đường",
      "所"  => "chỗ",
      "叠"  => "xấp",
      "骑"  => "cỗ",
      "锅"  => "nồi",
      "捧"  => "vốc",
      "身"  => "thân",
      "次"  => "lần",
      "数"  => "mấy",
      "趟"  => "chuyến",
      "响"  => "tiếng",
      "列"  => "nhóm",
      "批"  => "tốp",
      "枝"  => "cành",
      "顶"  => "đỉnh",
      "回"  => "hồi",
      "包"  => "bao",
      "针"  => "kim",
      "行"  => "hàng",
      "团"  => "đoàn",
      "样"  => "dạng",
      "格"  => "ô vuông",
      "起"  => "kiện",
      "纸"  => "giấy",
    }

    def self.has_key?(key : String)
      MAP_VAL.has_key?(key)
    end
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
