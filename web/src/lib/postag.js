export const labels = {
  n: 'Danh từ chung',
  nr: 'Tên người',
  ns: 'Địa danh',
  nt: 'Tổ chức',
  nw: 'Tác phẩm',
  ng: 'Ngữ tố danh từ',
  nz: 'Tên riêng khác',

  t: 'Thời gian',
  tg: 'Ngữ tố thời gian',

  s: 'Nơi chốn',
  f: 'Phương vị',

  v: 'Động từ chung',
  vshi: 'Động từ 是',
  vyou: 'Động từ 有',

  vn: 'Danh động từ',
  vd: 'Phó động từ',

  vf: 'Động từ xu hướng',
  vx: 'Động từ hình thái',

  vi: 'Nội động từ',
  vl: 'Cụm động từ',
  vg: 'Ngữ tố động từ',

  a: 'Tính từ chung',
  ad: 'Phó tính từ',
  an: 'Danh tính từ',
  al: 'Cụm tính từ',
  ag: 'Ngữ tố tính từ',

  b: 'Từ khu biệt',
  bl: 'Cụm từ khu biệt',

  z: 'Từ trạng thái',

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

  x: 'Hư từ',
  xx: 'Kaomoji',
  xu: 'Đường link',

  wd: '，',
  wn: ' 、',
  wj: ' 。',
  wx: '.',
  wm: '：',
  wf: '；',
  ws: '…',
  wp: '－',
  wi: '·',
  wt: '！',
  ww: '？',
  wb: '％ ‰',
  wh: '￥＄￡℃°',
  wyz: '“ ‘ 『「',
  wyy: '” ’ 』」',
  wkz: '（［｛',
  wky: '）］｝',
  wwz: '《〈',
  wwy: '》〉',
  w: 'Dấu câu khác',
}

export const gnames = ['Thường gặp', 'Hiếm gặp', 'Đặc biệt', 'Dấu câu']
export const groups = [
  // prettier-ignore
  [
    'n', 'nr', 'ns', 'nt', 'nw', 'nz', 't', 's', 'f',
    'v', 'vd', 'vn', 'vf', 'vx', 'vi', 'vl',
    'a', 'ad', 'an', 'al',
    'r', 'rr', 'rz', 'ry',
    'i', 'j', 'l'
  ],
  // prettier-ignore
  [
    'm', 'mq',
    'q', 'qv', 'qt',
    'b', 'bl', 'z',
    'ng', 'tg', 'vg', 'ag',
    'c', 'cc',
    'd', 'p', 'u',
    'e', 'y', 'o',
    'h', 'k',
    'x', 'xx', 'xu'
  ],
  // prettier-ignore
  [
    'vshi', 'vyou', 'pba', 'pbei',
    'uzhe', 'ule', 'uguo', 'ude1', 'ude2', 'ude3',
    'uzhi', 'ulian', 'udh', 'udeng', 'uyy',  'uls',
  ],
  // prettier-ignore
  [
    'wd', 'wn', 'wj', 'wx', 'wm', 'wf', 'wt', 'ww', 'ws',
    'wp', 'wi', 'wyz', 'wyy', 'wkz', 'wky', 'wwz', 'wwy',
    'wb', 'wh', 'w'
  ],
]

export function find_group(tag) {
  for (const [idx, group] of groups.entries()) {
    if (group.includes(tag)) return idx
  }

  return 0
}
