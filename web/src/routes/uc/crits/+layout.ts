import type { LayoutLoad } from './$types'

export const load = (async ({ parent }) => {
  return {
    _navs: [
      {
        href: '/uc',
        text: 'Nội dung từ người dùng',
        icon: 'users',
        show: 'ts',
        kind: 'title',
      },
      {
        href: '/uc/crits',
        text: 'Đánh giá truyện chữ',
        icon: 'stars',
        kind: 'title',
      },
    ],
    _curr: { text: 'Người dùng' },
  }
}) satisfies LayoutLoad
