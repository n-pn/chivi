import { home_nav, nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

export const load = (async ({ url: { searchParams, pathname } }) => {
  const ztext = searchParams.get('t') || ''
  const tmode = searchParams.get('m') || 'mtl_2'
  const pdict = searchParams.get('d') || 'combine'

  return {
    ztext,
    tmode,
    pdict,
    ontab: 'index',
    _title: 'Dịch đoạn văn',
    _meta: {
      left_nav: [
        home_nav(),
        nav_link('/mt/qtran', 'Dịch đoạn văn', 'language'),
      ],
    },
  }
}) satisfies PageLoad
