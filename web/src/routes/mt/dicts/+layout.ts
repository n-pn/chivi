import type { LayoutLoad } from './$types'

export const load = (async ({ parent }) => {
  const { _navs } = await parent()
  return { _navs: [..._navs, { href: '/mt/dicts', text: 'Từ điển', icon: 'package' }] }
}) satisfies LayoutLoad
