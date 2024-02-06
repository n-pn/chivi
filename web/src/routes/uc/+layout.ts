import type { LayoutLoad } from './$types'

export const load = (() => {
  return {
    _navs: [
      {
        href: '/uc',
        text: 'Nội dung từ người dùng',
        icon: 'users',
        kind: 'title',
      },
    ],
  }
}) satisfies LayoutLoad
