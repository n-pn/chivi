import type { LayoutLoad } from './$types'

export const load = (() => {
  return {
    ontab: 'lists',
    _navs: [
      {
        href: '/uc',
        text: 'Nội dung từ gười dùng',
        hd_text: 'Người dùng',
        hd_icon: 'users',
        hd_show: 'pl',
        hd_kind: 'title',
      },
      { href: '/uc/lists', text: 'Thư đơn', hd_icon: 'bookmarks' },
    ],
    _alts: [
      {
        href: '/uc/lists/+list',
        text: 'Tạo mới',
        hd_icon: 'square-plus',
        hd_show: 'pl',
        hd_kind: 'success',
      },
    ],
  }
}) satisfies LayoutLoad
