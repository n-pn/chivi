import { slugify } from './text_utils'

export const dict_labels = {
  '-1': 'Thông Dụng',
  '-2': 'Nền Tảng',
  '-3': 'Khoá Cứng',
  '-4': 'Tổng hợp',
  '-10': 'Hán Việt',
  '-11': 'Bính Âm',
  '-12': 'Họ tiếng Trung',
  '-20': 'Sửa danh từ',
  '-21': 'Sửa động từ',
  '-22': 'Sửa tính từ',
  '-23': 'Sửa phó từ',
  '-24': 'Sửa sau 之',
  '-25': 'Danh lượng từ',
  '-26': 'Động lượng từ',
  '-27': 'Thời lượng từ',
  '-28': 'Bổ ngữ xu hướng',
  '-29': 'Bổ ngữ kết quả',
  '-30': 'Động từ 2 tân',
  '-31': 'Động từ ly hợp',
}

export const dict_briefs = {
  '-1': 'Từ điển chung cho tất cả các bộ truyện',
  '-2': 'Từ điển cơ sở chung cho các chế độ dịch',
  '-3': 'Các từ nghĩa cố định dùng trong máy dịch',
  '-4': 'Từ điển tổng hợp dùng cho chế độ dịch nhanh',
  '-10': 'Từ điển phiên âm Hán Việt',
  '-11': 'Từ điển bính âm (pinyin)',
  '-12': 'Từ điển họ phổ biến tiếng Trung',
  '-20': 'Nghĩa của từ khi nó là danh từ',
  '-21': 'Nghĩa của từ khi nó là động từ',
  '-22': 'Nghĩa của từ khi nó là tính từ',
  '-23': 'Nghĩa của từ khi nó là phó từ',
  '-24': 'Đổi nghĩa của vế phải cụm từ kết hợp bởi 之',
  '-25': 'Lượng từ dành riêng cho danh từ',
  '-26': 'Lượng từ dành riêng cho động từ',
  '-27': 'Lượng từ chỉ đơn vị thời gian',
  '-28': 'Nghĩa của từ khi làm bổ ngữ xu hướng',
  '-29': 'Các loại bổ ngữ đứng sau động từ khác',
  '-30': 'Động từ yêu cầu 2 tân ngữ, tân ngữ trước thường chỉ người',
  '-31': 'Cụm động tân có thể tạo thành cấu trúc ly hợp, biểu hiện kỹ năng',
}

function make_brief(vd_id: number, label: string) {
  if (vd_id > 0) return `Từ điển riêng cho bộ truyện: ${label}`
  else return `Từ điển đặc biệt: ${label}`
}

export function make_vdict(
  vd_id: number,
  label?: string,
  brief?: string
): CV.Cvdict {
  label = label || dict_labels[vd_id] || vd_id
  brief = brief || dict_briefs[vd_id] || make_brief(vd_id, label)

  const dslug = `${vd_id}-${slugify(label)}`
  return { vd_id, label, brief, dslug }
}

export function upsert_dicts(vdict: CV.Cvdict, extra?: CV.Cvdict) {
  const { vd_id } = vdict
  extra = extra || make_vdict(-10)

  if (vd_id == 4 || vd_id > 0) return [vdict, make_vdict(-1), extra]
  else if (vd_id == -1) return [make_vdict(-4), vdict, extra]
  else return [make_vdict(-4), make_vdict(-1), vdict]
}
