module VietUtil
  extend self

  TONE_MAP = {
    "òa" => "oà",
    "óa" => "oá",
    "ỏa" => "oả",
    "õa" => "oã",
    "ọa" => "oạ",
    "òe" => "oè",
    "óe" => "oé",
    "ỏe" => "oẻ",
    "õe" => "oẽ",
    "ọe" => "oẹ",
    "ùy" => "uỳ",
    "úy" => "uý",
    "ủy" => "uỷ",
    "ũy" => "uỹ",
    "ụy" => "uỵ",
  }

  TONE_RE = Regex.new TONE_MAP.keys.join('|')

  # change vietnamese tones from old styles to new styles
  # ref: https://vi.wikipedia.org/wiki/Quy_t%E1%BA%AFc_%C4%91%E1%BA%B7t_d%E1%BA%A5u_thanh_trong_ch%E1%BB%AF_qu%E1%BB%91c_ng%E1%BB%AF

  def fix_tones(input : String)
    input.gsub(TONE_RE) { |x| TONE_MAP[x] }
  end
end
