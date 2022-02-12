const labels = {
  'cc_cedict': 'CC-CEDICT',
  'trungviet': 'Trung Việt',
  'hanviet': 'Hán Việt',
  'pin_yin': 'Bính Âm',
  'tradsim': 'Phồn Giản',
  'regular': 'Thông Dụng',
  'essence': 'Nền Tảng',
  'fixture': 'Khoá Cứng',
  '~fix_nouns': 'Sửa danh từ',
  '~fix_verbs': 'Sửa động từ',
  '~fix_adjts': 'Sửa tính từ',
  '~fix_u_zhi': 'Sửa sau 之',
  '~qt_times': 'Thời lượng từ',
  '~qt_verbs': 'Động lượng từ',
  '~qt_nouns': 'Danh lượng từ',
  '~v_compl': 'Bổ ngữ động từ',
  '~v2_objs': 'Động từ 2 tân',
}

const intros = {
  'combine': 'Từ điển tổng hợp dịch nhanh',
  'regular': 'Từ điển chung cho tất cả các bộ truyện',
  'hanviet': 'Từ điển phiên âm Hán Việt',
  'fixture': 'Các từ nghĩa cố định dùng trong máy dịch',
  'essence': 'Từ điển cơ sở chung cho các chế độ dịch',
  '~fix_u_zhi': 'Đổi nghĩa của vế phải cụm từ kết hợp bởi 之',
  '~qt_times': 'Lượng từ chỉ thời gian',
  '~qt_verbs': 'Lượng từ làm bổ ngữ cho động từ phía trước',
  '~qt_nouns': 'Lượng từ đếm với danh từ',
  '~v_compl': 'Những từ đứng sau động từ thì làm bổ ngữ cho nó',
  '~v2_objs': 'Động từ yêu cầu 2 tân ngữ, tân ngữ trước thường chỉ người',
}

export function upsert_dicts(vdict, extra) {
  extra = extra || make_vdict('hanviet')

  const { dname } = vdict
  if (dname == 'combine' || dname.charAt(0) == '$') {
    return [vdict, make_vdict('regular'), extra]
  } else {
    return [make_vdict('combine'), make_vdict('regular'), vdict]
  }
}

export function make_vdict(dname, d_dub, descs) {
  d_dub = d_dub || labels[dname] || dname
  descs = descs || intros[dname] || make_intro(dname, d_dub)
  return { dname, d_dub, descs }
}

function make_intro(dname, d_dub) {
  const prefix = dname.charAt(0)
  if (prefix != '$') return `Từ điển đặc biệt: ${d_dub}`
  return `Từ điển riêng cho bộ truyện: ${d_dub}`
}
