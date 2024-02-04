import type { LayoutLoad } from './$types'

export const load = (() => {
  return {
    ontab: 'lists',
    _navs: [
      {
        href: '/uc',
        text: 'Nội dung người dùng',
        hd_icon: 'article',
        hd_show: 'pl',
      },
      { href: '/uc/lists', text: 'Thư đơn', hd_icon: 'bookmarks' },
    ],
  }
}) satisfies LayoutLoad
