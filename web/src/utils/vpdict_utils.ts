const labels = {
  '$hanviet': 'Hán Việt',
  '$pin_yin': 'Bính Âm',
  '$surname': 'Họ tiếng Trung',
  'regular': 'Thông Dụng',
  'essence': 'Nền Tảng',
  'fixture': 'Khoá Cứng',
  'combine': 'Tổng hợp',
  '~fix_nouns': 'Sửa danh từ',
  '~fix_verbs': 'Sửa động từ',
  '~fix_adjts': 'Sửa tính từ',
  '~fix_adverbs': 'Sửa phó từ',
  '~fix_u_zhi': 'Sửa sau 之',
  '~qt_times': 'Thời lượng từ',
  '~qt_verbs': 'Động lượng từ',
  '~qt_nouns': 'Danh lượng từ',
  '~verb_com': 'Bổ ngữ động từ',
  '~verb_dir': 'Động từ xu hướng',
  '~v_group': 'Động từ ly hợp',
  '~v2_objs': 'Động từ 2 tân',
}

const intros = {
  'combine': 'Từ điển tổng hợp dịch nhanh',
  'regular': 'Từ điển chung cho tất cả các bộ truyện',
  'fixture': 'Các từ nghĩa cố định dùng trong máy dịch',
  'essence': 'Từ điển cơ sở chung cho các chế độ dịch',
  '$hanviet': 'Từ điển phiên âm Hán Việt',
  '$pin_yin': 'Từ điển bính âm',
  '~fix_u_zhi': 'Đổi nghĩa của vế phải cụm từ kết hợp bởi 之',
  '~qt_times': 'Lượng từ chỉ thời gian',
  '~qt_verbs': 'Lượng từ làm bổ ngữ cho động từ phía trước',
  '~qt_nouns': 'Lượng từ đếm với danh từ',
  '~verb_dir':
    'Bổ ngữ xu hướng cho động từ, có thể đứng trước hoặc sau tân ngữ',
  '~verb_com': 'Các loại bổ ngữ đứng sau động từ khác',
  '~v_group': 'Cấu trúc động từ ly hợp, biểu hiện kỹ năng',
  '~v2_objs': 'Động từ yêu cầu 2 tân ngữ, tân ngữ trước thường chỉ người',
}

export function upsert_dicts(vdict: CV.VpDict, extra: CV.VpDict) {
  extra = extra || make_vdict('$hanviet')
  const { dname } = vdict

  if (dname == 'combine' || dname.startsWith('-')) {
    return [vdict, make_vdict('regular'), extra]
  } else if (dname == 'regular') {
    return [make_vdict('combine'), vdict, extra]
  } else {
    return [make_vdict('combine'), make_vdict('regular'), vdict]
  }
}

// prettier-ignore
export function make_vdict( dname: string, d_dub?: string, d_tip?: string ): CV.VpDict {
  d_dub = d_dub || labels[dname] || dname
  d_tip = d_tip || intros[dname] || make_intro(dname, d_dub)
  return { dname, d_dub, d_tip }
}

function make_intro(dname: string, d_dub: string) {
  if (dname.startsWith('~')) return `Từ điển đặc biệt: ${d_dub}`
  return `Từ điển riêng cho bộ truyện: ${d_dub}`
}
