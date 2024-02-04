import type { LayoutLoad } from './$types'

export const load = (() => {
  return {
    _navs: [{ href: '/uc', text: 'Người dùng', hd_icon: 'users' }],
  }
}) satisfies LayoutLoad
