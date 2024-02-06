import type { LayoutLoad } from './$types'

export const load = (() => {
  return {
    _navs: [
      {
        href: '/rm',
        text: 'Nguồn liên kết nhúng',
        icon: 'world',
        kind: 'title',
      },
    ],
  }
}) satisfies LayoutLoad
