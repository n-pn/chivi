# require "./_utils"
require "./tl_unit"
require "../mt_data/mt_node"

module MT::TlChap
  LBLS = {
    "季" => "Mùa",
    "卷" => "Quyển",
    "集" => "Tập",
    "章" => "Chương",
    "节" => "Tiết",
    "幕" => "Màn",
    "回" => "Hồi",
    "折" => "Chiết",
  }

  NUMS = "零〇一二两三四五六七八九十百千０-９"
  DIVS = "章节幕回折"

  CHDIV_RE_1 = /^(\p{Ps}?第?([#{NUMS}]+)([集卷季])\p{Pe}?)([\p{P}　]*)(.*)$/
  TITLE_RE_1 = /^(第　*([#{NUMS}]+)　*([#{DIVS}]))([\p{P}　]*)(.*)$/
  TITLE_RE_2 = /^([０-９]*\p{Ps}?([#{NUMS}]+)\p{Pe}?([#{DIVS}]))([\p{P}　]*)(.*)$/

  TITLE_RE_3 = /^([０-９]+)([\p{P}\s　]*)(.*)$/
  TITLE_RE_4 = /^(序章|楔子)([\s　]*)(.+)$/

  TRANS = {
    "序章" => "Mở đầu",
    "楔子" => "Phần đệm",
  }

  # returning chap zh_label, vi_label, padding (trash) + zh_title
  def self.split(title : String)
    if match = CHDIV_RE_1.match(title) || TITLE_RE_1.match(title) || TITLE_RE_2.match(title)
      _, zh_ch, digit, c_lbl, trash, title = match
      vi_ch = "#{LBLS[c_lbl]} #{TlNumber.translate(digit, scale: 1)}"
    elsif match = TITLE_RE_3.match(title)
      _, zh_ch, trash, title = match
      vi_ch = CharUtil.normalize(zh_ch)
    elsif match = TITLE_RE_4.match(title)
      _, zh_ch, trash, title = match
      vi_ch = TRANS[zh_ch]
    else
      return {title, nil}
    end

    zh_ch += trash
    vi_ch += ':' unless title.empty?

    defn = DefnData.new(vstr: vi_ch, attr: :capn, dnum: :auto_fix, epos: :LST)
    node = MtNode.new(body: defn, epos: :LST, zstr: zh_ch, from: 0)

    {title, node}
  end

  # puts split("第１章　业余的悍匪")
  # puts split("第１０３章长河决堤")
end
