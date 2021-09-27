export const labels = {
  n: 'Danh từ',
  nr: 'Tên người',
  nf: 'Dòng họ',
  ns: 'Địa danh',
  nt: 'Tổ chức',
  nw: 'Danh xưng',
  ng: 'Ngữ tố danh từ',
  nz: 'Tên riêng khác',

  t: 'Thời gian',
  tg: 'Ngữ tố thời gian',

  nl: 'Cụm danh từ',
  s: 'Nơi chốn',
  f: 'Phương vị',

  v: 'Động từ',
  vshi: 'Động từ 是',
  vyou: 'Động từ 有',

  vn: 'Danh động từ',
  vd: 'Trạng động từ',

  vf: 'Động từ xu hướng',
  vx: 'Động từ hình thái',

  vi: 'Nội động từ',
  vl: 'Cụm động từ',
  vg: 'Ngữ tố động từ',

  a: 'Hình dung từ',
  ad: 'Trạng hình từ',
  an: 'Danh hình từ',
  al: 'Cụm tính từ',
  ag: 'Ngữ tố tính từ',
  az: 'Từ trạng thái',

  ahao: 'Tính từ 好',

  b: 'Từ khu biệt',
  bl: 'Cụm từ khu biệt',

  r: 'Đại từ',
  rr: 'Đại từ nhân xưng',
  rz: 'Đại từ chỉ thị',
  ry: 'Đại từ nghi vấn',

  m: 'Số từ',
  mq: 'Số lượng từ',

  q: 'Lượng từ',
  qv: 'Lượng động từ',
  qt: 'Lượng từ thời gian',

  i: 'Thành ngữ',
  j: 'Viết tắt',
  l: 'Quán ngữ',

  d: 'Trạng từ',
  p: 'Giới từ',
  pba: 'Giới từ 把',
  pbei: 'Giới từ 被',

  c: 'Liên từ',
  cc: 'Liên từ liệt kê',

  u: 'Trợ từ',
  uzhe: 'Trợ từ 着',
  ule: 'Trợ từ 了',
  uguo: 'Trợ từ 过',
  ude1: 'Trợ từ 的',
  ude2: 'Trợ từ 地',
  ude3: 'Trợ từ 得',
  usuo: 'Trợ từ 所',
  uzhi: 'Trợ từ 之',
  ulian: 'Trợ từ 连',
  udh: 'Trợ từ 的话',
  udeng: '等/等等/云云',
  uyy: '一样/一般/...',
  uls: '来讲/而言/...',

  e: 'Thán từ',
  y: 'Ngữ khí',
  o: 'Tượng thanh',

  h: 'Tiền tố',
  k: 'Hậu tố',

  x: 'Chữ latin',
  xd: 'Số latin',
  xx: 'Kaomoji',
  xu: 'Đường link',

  wj: 'Dấu chấm 。',
  wx: 'Dấu chấm .',
  wd: 'Dấu phẩy ,',
  wn: 'Phẩy nối 、',
  wm: 'Hai chấm :',
  ws: 'Ba chấm …',
  wp: 'Gạch ngang —',
  wmd: 'Chấm giữa ·',
  wsc: 'Chấm phẩy ;',
  wex: 'Chấm than !',
  wqs: 'Chấm hỏi ?',
  wti: 'Dấu ngã ~',
  wpc: '％ ‰',
  wqt: '￥＄￡℃°',
  wyz: 'Mở trích',
  wyy: 'Đóng trích',
  wkz: 'Mở ngoặc',
  wky: 'Đóng ngoặc',
  wwz: 'Mở tựa',
  wwy: 'Đóng tựa',
  w: 'Dấu câu',

  kmen: 'Hậu tố 们',
  kshi: 'Hậu tố 时',
  vneng: 'Động từ 能',
  vhui: 'Động từ 会',
  vxiang: 'Động từ 想',
}

export const gnames = ['Thường gặp', 'Hiếm gặp', 'Đặc biệt']
export const groups = [
  // prettier-ignore
  [
    'nr', 'nf', 'ns', 'nt', 'nz',
    '-',
    'n', 'nl', 'nw', 't', 's', 'f', 'ng',  'tg',
    '-',
    'v', 'vd', 'vf', 'vx', 'vi', 'vl', 'vn',  'vg',
    '-',
    'a', 'ad', 'an', 'az', 'al',  'b', 'bl', 'ag',
    '-',
    'r', 'rr', 'rz', 'ry',
    '-',
    'i', 'j', 'l'
  ],
  // prettier-ignore
  [
    'm', 'mq', 'q', 'qv', 'qt',
    '-',
     'c', 'cc',
    'd', 'p', 'u',
    'e', 'y', 'o',
    '-',
    'h', 'k',
    'x', 'xd', 'xx', 'xu'
  ],
  // prettier-ignore
  [
    'vshi', 'vyou', 'vneng', 'vhui', 'vxiang',
    'pba', 'pbei',
    'ahao',
    '-',
    'uzhe', 'ule', 'uguo', 'ude1', 'ude2', 'ude3', 'uzhi', 'ulian',
    '-',
    'udh', 'udeng', 'uyy',  'uls',
    '-',
    'kmen', 'kshi',
    'wd', 'wn', 'wj', 'wx', 'wm', 'wf', 'wt', 'ww', 'ws',
    'wp', 'wi',
    '-',
    'wyz', 'wyy', 'wkz', 'wky', 'wwz', 'wwy',
    '-',
    'wb', 'wh', 'w'
  ],
]

export function tag_label(tag) {
  return labels[tag] || tag
}

export function find_group(tag) {
  for (const [idx, group] of groups.entries()) {
    if (group.includes(tag)) return idx
  }

  return -1
}
