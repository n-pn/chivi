import type { LayoutLoad } from './$types'

export const load = (() => {
  return { _navs: [{ href: '/ts', text: 'Đọc truyện', hd_icon: 'book-2' }] }
}) satisfies LayoutLoad
