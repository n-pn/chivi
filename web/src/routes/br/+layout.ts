import type { LayoutLoad } from './$types'

export const load = (() => {
  return {
    _navs: [{ href: '/br', text: 'Đánh giá truyện chữ', hd_icon: 'stars' }],
  }
}) satisfies LayoutLoad
