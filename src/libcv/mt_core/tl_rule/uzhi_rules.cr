module CV::TlRule
  FIX_UZHI = {
    "列" => "hàng ngũ",
    "才" => "tài hoa",
    "心" => "lòng",
    "别" => "khác biệt",
    "机" => "cơ hội",
    "子" => "con trai",
    "意" => "ý",
    "主" => "chủ nhân",
    "路" => "con đường",
    "事" => "chuyện",
    "悟" => "tỉnh ngộ",
    "泪" => "nước mắt",
    "痛" => "nỗi đau",
    "怒" => "cơn giận",
    "战" => "cuộc chiến",
    "色" => "vẻ",
    "士" => "kẻ",
    "能" => "năng lực",
    "躯" => "thân thể",
    "力" => "lực lượng",
    "歌" => "bài hát",
    "眼" => "con mắt",
    "感" => "cảm giác",
    "手" => "bàn tay",
    "首" => "đứng đầu",
    "地" => "vùng đất",
    "辈" => "hạng người",
    "因" => "nguyên nhân",
    "交" => "quan hệ",
    "隐" => "nỗi niềm",
    "长" => "đứng đầu",
    "乐" => "niềm vui",
    "森" => "rừng rậm",
    "作" => "tác phẩm",
    "泉" => "dòng suối",
    "星" => "ngôi sao",
    "火" => "ngọn lửa",
    "姿" => "dung mạo",
    "秀" => "nhân tài",
    "谈" => "lời",
    "想" => "ý nghĩ",
    "区" => "chỗ",
    "资" => "tư chất",
    "忧" => "nỗi lo",
    "灾" => "hoạ",
    "年" => "tuổi",
    "患" => "tai hoạ",
    "亲" => "quan hệ",
    "见" => "tầm nhìn",
    "极" => "cực kỳ",
    "门" => "cánh cửa",
    "美" => "vẻ đẹp",
    "兆" => "điềm",
    "癖" => "ham thích",
    "计" => "kế sách",
    "物" => "của",
    "位" => "ngôi",
    "徒" => "kẻ",
    "祖" => "ông tổ",
    "秘" => "bí mật",
    "论" => "lời",
    "功" => "công lao",
  }

  def fold_uzhi!(node : MtNode, prev = node.prev, succ = node.succ?) : MtNode
    return node unless succ

    case succ.key
    when "都"
      prev.tag = PosTag::Locname
      succ.val = "kinh đô"
    else
      prev.tag = PosTag::Nform
      succ.val = FIX_UZHI[succ.key]? || succ.val
    end

    prev.dic = 6
    prev.val = "#{succ.val} #{prev.val}"
    prev.fold_many!(node, succ)
  end
end
