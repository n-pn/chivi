import type { LayoutLoad } from './$types'

export const load = (async ({ parent }) => {
  return {
    _navs: [
      {
        href: '/uc',
        text: 'Nội dung từ gười dùng',
        hd_text: 'Người dùng',
        hd_icon: 'users',
        hd_show: 'ts',
        hd_kind: 'title',
      },
      {
        href: '/uc/crits',
        text: 'Đánh giá truyện chữ',
        hd_icon: 'stars',
        hd_kind: 'title',
      },
    ],
  }
}) satisfies LayoutLoad
