import type { PageLoad } from './$types'

export const load = (async ({ url: { searchParams, pathname } }) => {
  const pdict = searchParams.get('pdict') || 'combine'
  const tmode = searchParams.get('tmode') || 'mtl_2'

  return {
    pdict,
    tmode,
    ontab: 'multi',
    _title: 'Dịch đoạn văn',
    _meta: {
      left_nav: [{ text: 'Dịch nhanh', icon: 'bolt', href: pathname }],
    },
  }
}) satisfies PageLoad
