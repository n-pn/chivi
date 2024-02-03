import type { PageLoad } from './$types'

export const load = (async ({ parent }) => {
  const { rstem, _navs } = await parent()

  return {
    ontab: 'bants',
    _meta: `Thảo luận - ${rstem.btitle_vi}`,
    _navs: [..._navs, { href: 'bants', text: 'Thảo luận' }],
  }
}) satisfies PageLoad
