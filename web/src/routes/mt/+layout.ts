import type { LayoutLoad } from './$types'

export const load = (() => {
  return { _navs: [{ href: '/mt', text: 'Máy dịch', icon: 'engine' }] }
}) satisfies LayoutLoad
