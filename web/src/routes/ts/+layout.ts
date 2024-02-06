import type { LayoutLoad } from './$types'

export const load = (() => {
  return { _navs: [{ href: '/ts', text: 'Đọc truyện', icon: 'book-2' }] }
}) satisfies LayoutLoad
