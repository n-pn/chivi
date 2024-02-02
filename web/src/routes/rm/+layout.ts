import type { LayoutLoad } from './$types'

export const load = (() => {
  return {
    _navs: [
      {
        href: '/rm',
        text: 'Nguồn liên kết nhúng',
        hd_icon: 'world',
        hd_kind: 'title',
      },
    ],
  }
}) satisfies LayoutLoad
