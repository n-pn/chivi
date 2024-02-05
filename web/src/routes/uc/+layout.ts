import type { LayoutLoad } from './$types'

export const load = (() => {
  return {
    _navs: [
      {
        href: '/uc',
        text: 'Nội dung từ người dùng',
        hd_icon: 'users',
        hd_kind: 'title',
      },
    ],
  }
}) satisfies LayoutLoad
