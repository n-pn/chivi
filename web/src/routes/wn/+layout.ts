import type { LayoutLoad } from './$types'

export const load = (() => {
  return {
    _navs: [{ href: '/wn', text: 'Thư viện truyện chữ', hd_icon: 'books' }],
  }
}) satisfies LayoutLoad
