import type { LayoutLoad } from './$types'

export const load = (() => {
  return {
    ontab: 'lists',
    _prev: { text: 'Người dùng', show: 'pl' },
    _navs: [
      { href: '/uc', text: 'Nội dung từ người dùng', icon: 'users' },
      { href: '/uc/lists', text: 'Thư đơn', icon: 'bookmarks' },
    ],
    _alts: [
      {
        href: '/uc/lists/+list',
        text: 'Tạo mới',
        icon: 'square-plus',
        show: 'pl',
        kind: 'success',
      },
    ],
  }
}) satisfies LayoutLoad
