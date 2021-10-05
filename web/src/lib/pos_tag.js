export const labels = {
  ns: 'Địa danh',
  nt: 'Tổ chức',
  nz: 'Tên riêng khác',
  nr: 'Tên người',
  nf: 'Dòng họ',
  nw: 'Danh xưng',

  n: 'Danh từ',
  s: 'Nơi chốn',
  f: 'Phương vị',
  t: 'Thời gian',
  ng: 'Ngữ tố danh từ',
  tg: 'Ngữ tố thời gian',

  a: 'Hình dung từ',
  b: 'Khu biệt từ',
  az: 'Trạng thái từ',
  an: 'Danh hình từ',
  ad: 'Phó hình từ',
  ag: 'Ngữ tố tính từ',

  v: 'Động từ',
  vd: 'Phó động từ',
  vn: 'Danh động từ',
  vi: 'Nội động từ',
  vf: 'Động từ xu hướng',
  vx: 'Động từ hình thức',
  vg: 'Ngữ tố động từ',

  rr: 'Đại từ nhân xưng',
  rz: 'Đại từ chỉ thị',
  ry: 'Đại từ nghi vấn',
  r: 'Đại từ chưa phân loại',

  i: 'Thành/quán ngữ',
  nl: 'Cụm danh từ',
  vl: 'Cụm động từ',
  al: 'Cụm hình dung từ',
  bl: 'Cụm khu biệt từ',

  m: 'Số từ',
  mx: 'Số latin',
  q: 'Lượng từ',
  qv: 'Lượng động từ',
  qt: 'Lượng từ thời gian',
  mq: 'Số + lượng từ',

  d: 'Phó từ',
  c: 'Liên từ',
  cc: 'Liên từ liệt kê',
  p: 'Giới từ',
  u: 'Trợ từ',
  e: 'Thán từ',
  y: 'Ngữ khí',
  o: 'Tượng thanh',

  // affixes
  kn: 'Hậu tố danh từ',
  ka: 'Hậu tố tính từ',
  kv: 'Hậu tố động từ',

  kmen: 'Hậu tố 们',
  kshi: 'Hậu tố 时',
  k: 'Hậu tố chưa phân loại',

  // specials
  ahao: 'Tính từ 好',
  vshi: 'Động từ 是',
  vyou: 'Động từ 有',
  vneng: 'Động từ 能',
  vhui: 'Động từ 会',
  vxiang: 'Động từ 想',

  pba: 'Giới từ 把',
  pbei: 'Giới từ 被',

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

  x: 'Chữ latin',
  xx: 'Kaomoji',
  xu: 'Đường link',

  wj: 'Dấu chấm 。',
  wx: 'Dấu chấm .',
  wd: 'Dấu phẩy ,',
  wn: 'Dấu ngắt 、',
  wm: 'Hai chấm :',
  ws: 'Ba chấm …',
  wp: 'Gạch ngang —',
  wmd: 'Chấm giữa ·',
  wex: 'Chấm than !',
  wqs: 'Chấm hỏi ?',
  wsc: 'Chấm phẩy ;',
  wti: 'Dấu ngã ~',
  wat: 'A còng @',
  wps: 'Dấu cộng +',
  wms: 'Dấu trừ -',
  wpc: '％ ‰',
  wqt: '￥＄￡℃°',
  wyz: 'Mở trích',
  wyy: 'Đóng trích',
  wkz: 'Mở ngoặc',
  wky: 'Đóng ngoặc',
  wwz: 'Mở tựa',
  wwy: 'Đóng tựa',
  w: 'Dấu câu khác',
}

export const gnames = ['Cơ bản', 'Đặc biệt', 'Dấu câu']
export const groups = [
  // prettier-ignore
  [
    'ns','nt', 'nz',
    'nr', 'nf',
    '-',
    'n', 'nw', 't',
    's', 'f',
    '-',
    'a', 'an', 'ad',
    'b', 'az',
    '-',
    'v', 'vn', 'vd',
    'vi', 'vf', 'vx',
    '-',
    'i', 'nl', 'vl',
    'al', 'bl',
    '-',
    'rr', 'rz', 'ry',
    'r',
  ],
  // prettier-ignore
  [
    'm', 'mx', 'q',
    'qv', 'qt', 'mq',
    '-',
    'd', 'p', 'u',
    'c', 'cc', 'e',
    'y', 'o',
    '-',
    'ng', 'ag', 'vg', 'tg',
    '-',
    'kn', 'ka', 'kv',
    'kmen', 'kshi', 'k',
    '-',
    'ahao', 'vshi', 'vyou',
    'vneng','vhui', 'vxiang',
    'pba', 'pbei',
    '-',
    'uzhe', 'ule', 'uguo',
    'ude1', 'ude2', 'ude3',
    'uzhi', 'ulian', 'udh',
    'udeng', 'uyy', 'uls',
    '-',
    'x', 'xx', 'xu',
  ],
  // prettier-ignore
  [
    'wj','wx', 'wd',
    'wn', 'wm', 'ws',
    'wp', 'wmd', 'wex',
    'wqs', 'wsc', 'wti',
    'wat', 'wps', 'wms',
    'wpc', 'wqt', 'wyz',
    'wyy', 'wkz', 'wky',
    'wwz', 'wwy', 'w'
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
