import type { PageLoad } from './$types'

export const load = (async ({ url: { searchParams, pathname } }) => {
  const ztext = searchParams.get('text') || ''
  const tmode = searchParams.get('mode') || 'mtl_2'
  const pdict = searchParams.get('dict') || 'combine'

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
