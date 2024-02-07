import type { LayoutData } from './$types'

export const load = (async ({ parent }) => {
  const { _navs } = await parent()

  return {
    _navs: [..._navs, { text: 'Dịch nhanh', icon: 'bolt', href: '/mt/qtran' }],
  }
}) satisfies LayoutData
