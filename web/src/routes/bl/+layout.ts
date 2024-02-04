import type { LayoutLoad } from './$types'

export const load = (() => {
  return {
    _navs: [
      {
        href: '/wn',
        text: 'Thư viện truyện chữ',
        hd_icon: 'books',
        hd_show: 'pl',
      },
      { href: '/wn/lists', text: 'Thư đơn', hd_icon: 'bookmarks' },
    ],
  }
}) satisfies LayoutLoad
