import type { LayoutLoad } from './$types'

export const load = (() => {
  return { _navs: [{ href: '/up', text: 'Sưu tầm cá nhân', hd_icon: 'album' }] }
}) satisfies LayoutLoad
