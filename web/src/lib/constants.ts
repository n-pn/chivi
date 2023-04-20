export const status_types = [
  'default',
  'reading',
  'finished',
  'onhold',
  'dropped',
  'pending',
]

export const status_names = {
  default: 'Đánh dấu',
  reading: 'Đang đọc',
  finished: 'Hoàn thành',
  onhold: 'Tạm dừng',
  dropped: 'Vứt bỏ',
  pending: 'Đọc sau',
}

export const status_icons = {
  default: 'bookmark',
  reading: 'eye',
  finished: 'square-check',
  onhold: 'player-pause',
  dropped: 'trash',
  pending: 'calendar',
}

export const status_colors = {
  default: 'neutral',
  reading: 'primary',
  finished: 'success',
  onhold: 'warning',
  dropped: 'harmful',
  pending: 'private',
}

export const bgenres: Array<[string, string, boolean]> = [
  ['Loại khác', 'loai-khac', false],
  ['Huyền ảo', 'huyen-ao', true],
  ['Kỳ huyễn', 'ky-huyen', true],
  ['Giả tưởng', 'gia-tuong', false],
  ['Ma pháp', 'ma-phap', false],
  ['Lịch sử', 'lich-su', true],
  ['Quân sự', 'quan-su', false],
  ['Đô thị', 'do-thi', true],
  ['Hiện thực', 'hien-thuc', false],
  ['Chức trường', 'chuc-truong', false],
  ['Quan trường', 'quan-truong', false],
  ['Vườn trường', 'vuon-truong', false],
  ['Thương chiến', 'thuong-chien', false],
  ['Tiên hiệp', 'tien-hiep', false],
  ['Tu chân', 'tu-chan', true],
  ['Khoa viễn', 'khoa-vien', true],
  ['Không gian', 'khong-gian', false],
  ['Trò chơi', 'tro-choi', true],
  ['Thể thao', 'the-thao', true],
  ['Thi đấu', 'thi-dau', false],
  ['Huyền nghi', 'huyen-nghi', true],
  ['Kinh dị', 'kinh-di', true],
  ['Thần quái', 'than-quai', false],
  ['Đồng nhân', 'dong-nhan', true],
  ['Võ hiệp', 'vo-hiep', true],
  ['Đam mỹ', 'dam-my', false],
  ['Nữ sinh', 'nu-sinh', false],
  ['Ngôn tình', 'ngon-tinh', true],
  ['Xuyên việt', 'xuyen-viet', false],
  ['Trạch văn', 'trach-van', true],
  ['Phi sắc', 'phi-sac', true],
  ['Lý phiên', 'ly-phien', true],
]

export const snames = [
  'hetushu',
  'zxcs_me',
  '69shu',
  'ptwxz',
  'uukanshu',
  'rengshu',
  'xbiquge',
  'paoshu8',
  'biqu5200',
  'bxwxorg',
  'biqugee',
  'sdyfcm',
  'duokan8',
  'shubaow',
]

export const book_origins = [
  'qidian',
  'zongheng',
  'ciweimao',
  '17k',
  'faloo',
  'chuangshi',
  'jjwxc',
  'sfacg',
  'zhulang',
  'laikan',
  '8kana',
  'youdubook',
  'kanshu',
]

export const order_names = {
  bumped: 'Vừa xem',
  update: 'Đổi mới',
  rating: 'Đánh giá',
  weight: 'Tổng hợp',
}

export const dlabels = {
  'Thảo luận': 1,
  'Chia sẻ': 2,
  'Thắc mắc': 3,
  'Yêu cầu': 4,
  'Dịch thuật': 5,
}
