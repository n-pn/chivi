import type { PageLoad } from './$types'

export const load = (async ({ url: { searchParams, pathname } }) => {
  const ztext = searchParams.get('zh') || ''
  const tmode = searchParams.get('tm') || 'mtl_2'

  const pdict = searchParams.get('pdict') || 'combine'

  return {
    ztext,
    tmode,
    pdict,
    ontab: 'index',
    _title: 'Dịch đoạn văn',
    _meta: {
      left_nav: [{ text: 'Dịch đoạn văn', icon: 'language', href: pathname }],
    },
  }
}) satisfies PageLoad
