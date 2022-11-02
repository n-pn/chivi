def self.from_key(key : String)
  attr = self.can_chain?(key) ? Chain : None
  return attr if key.size == 1

  case key[-1]?
  when '了' then attr | HasUle
    # when '在' then attr |= HasPzai
    # when '得' then attr |= HasUde3
  when '着' then attr | HasUzhe | Chain
  when '下', '上', '出', '进', '回',
       '过', '起', '来', '去'
    attr | DirCompl
  when '好', '完', '错', '晚', '坏',
       '饱', '清', '到', '走', '会',
       '懂', '见', '掉'
    attr | ResCompl
  else
    attr
  end
end

def self.vlinking?(key : String)
  {'来', '去', '到', '出'}.includes?(key[0])
end

DIRECTION = {
  "上"  => "lên",
  "下"  => "xuống",
  "进"  => "vào",
  "出"  => "ra",
  "过"  => "qua",
  "去"  => "đi",
  "回"  => "trở về",
  "起"  => "lên",
  "来"  => "tới",
  "上来" => "đi đến",
  "上去" => "đi lên",
  "下来" => "lại",
  "下去" => "xuống",
  "进来" => "tiến đến",
  "进去" => "đi vào",
  "出来" => "đi ra",
  "出去" => "ra ngoài",
  "过来" => "qua tới",
  "过去" => "qua",
  "回来" => "trở về",
  "回去" => "trở lại",
  "起来" => "lên",
}

COMPARE = {
  "如"  => "tựa",
  "像"  => "giống",
  "仿佛" => "giống",
  "宛若" => "giống",
  "好像" => "thật giống",
}

AUXILS = {
  "爱"   => "yêu",
  "喜欢"  => "thích",
  "避免"  => "tránh",
  "加以"  => "tiến hành",
  "进行"  => "tiến hành",
  "予以"  => "ban cho",
  "着手"  => "lấy tay",
  "舍得"  => "nỡ bỏ",
  "忍不住" => "không nhịn được",
}
