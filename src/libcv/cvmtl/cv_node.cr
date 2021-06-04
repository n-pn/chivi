require "../../cutil/text_utils"
require "../vdict/vp_term"

class CV::CvNode
  property key : String
  property val : String

  property dic : Int32
  property cat : Int32 = 0

  property prev : self | Nil = nil
  property succ : self | Nil = nil

  def initialize(term : VpTerm)
    @key = term.key
    @val = term.vals.first
    @cat = term.attr
    @dic = term.dtype
  end

  def initialize(@key, @val = @key, @dic = 0, @cat = 0)
  end

  def set_prev(node : self) : self # return node
    if _prev = @prev
      _prev.succ = node
      node.prev = _prev
    end

    node.succ = self
    @prev = node
  end

  def set_succ(node : self) : self # return node
    if _succ = @succ
      _succ.prev = node
      node.succ = _succ
    end

    node.prev = self
    @succ = node
  end

  def set_succ(node : Nil)
    @succ = nil
  end

  def fix(@val : String, @dic = 9, @cat = @cat) : Nil
  end

  def match_key?(key : String)
    @key == key
  end

  @[AlwaysInline]
  def word?
    @dic > 0
  end

  @[AlwaysInline]
  def noun?
    @cat & 1 != 0
  end

  @[AlwaysInline]
  def verb?
    @cat & 2 != 0
  end

  @[AlwaysInline]
  def adje?
    @cat & 4 != 0
  end

  def capitalize!(cap_mode : Int32 = 1) : Nil
    @val = cap_mode > 1 ? TextUtils.titleize(@val) : TextUtils.capitalize(@val)
  end

  def special_mid_char?
    case @key[0]?
    when ':', '/', '.', '-', '+', '?', '%', '#', '&'
      true
    else
      false
    end
  end

  def match_rule_对?
    if @dic == 0
      @val[0]? == '“'
    else
      @key != "的"
    end
  end

  def letter?
    @dic > 0
  end

  def special_end_char?
    case @key[0]?
    when '-', '+', '?', '%', '°'
      true
    else
      false
    end
  end

  def similar?(other : self)
    return false if @dic != other.dic || @dic > 1
    return true if @dic == 1
    @key[0] == other.key[0]
  end

  def absorb_similar!(other : CvNode) : Nil
    @key = "#{other.key}#{@key}"
    @val = "#{other.val}#{@val}"
  end

  def merge!(key : String, val : String, cat : Int32 = 0, dic = @dic)
    @key = "#{@key}#{key}"
    @val = "#{@val} #{val}"
    @cat |= cat
    @dic = dic
  end

  def to_i?
    @key.to_i?
  end

  def clear!
    @key = ""
    @val = ""
    @dic = 0
  end

  def pronoun?
    case @key
    when "我", "你", "您", "他", "她", "它",
         "我们", "咱们", "你们", "您们", "他们", "她们", "它们",
         "朕", "人家", "老子"
      true
    else
      false
    end
  end

  def person?
    @val[0]?.try(&.uppercase?) || pronoun?
  end

  NUM = "零〇一二两三四五六七八九十百千万亿"
  PRE = ""
  SUB = ""

  # TODO: add more words
  NUM_RE = /^[\p{N}#{NUM}]+$/
  getter is_num : Bool { NUM_RE === @key }

  INT_RE = /^\d+$/
  getter is_int : Bool { INT_RE === @key }

  QUANTI = ""

  # link: https://chinese.com.vn/luong-tu-trong-tieng-trung.html
  def quanti?
    case @key[-1]?
    when '个', '块', '双', '盘', '张', '副', '家', '盒', '支', '瓶',
         '只', '碗', '件', '朵', '本', '条', '头', '面', '道', '份',
         '把', '部', '幅', '包', '串', '顶', '堵', '对', '封', '根',
         '罐', '户', '架', '间', '斤', '句', '卷', '棵', '课', '口',
         '辆', '轮', '匹', '起', '群', '首', '艘', '台', '位', '枝',
         '座', '丸', '令', '俩', '具', '出', '刀', '列', '则', '剂',
         '发', '名', '员', '回', '团', '场', '堂', '杆', '束', '枚',
         '株', '桩', '桶', '段', '炷', '片', '班', '瓣', '盏', '眼',
         '种', '窝', '笔', '筒', '管', '箩', '篇', '粒', '纸', '缕',
         '股', '行', '身', '轴', '通', '重', '铺', '锭', '门', '阵',
         '项', '顿', '领', '颗'
      true
    else
      false
    end
  end

  QUANTI_RE = /^[\p{N}#{NUM}]+/

  def quanti_mics?
    return false unless quanti?
    @key.matches?(QUANTI_RE)
  end

  # link: https://chinese.com.vn/cac-phuong-vi-tu-trong-tieng-trung-va-cach-su-dung-phuong-vi-tu.html

  def locality?
    case @key
    when "前", "后", "左", "右", "上", "下", "里", "外",
         "前面", "后面", "左面", "右面", "上面", "下面", "里面", "外面",
         "前边", "后边", "左边", "右边", "上边", "下边", "里边", "外边"
      true
    else
      false
    end
  end

  def to_str(io : IO)
    io << @key << 'ǀ' << @val << 'ǀ' << @dic
  end

  def inspect(io : IO)
    io << (@key.empty? ? @val : "[#{@key}¦#{@val}¦#{@dic}]")
  end
end
