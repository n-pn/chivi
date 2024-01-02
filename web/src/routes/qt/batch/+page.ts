import type { PageLoad } from './$types'

export const load = (async ({ url: { searchParams, pathname } }) => {
  const pdict = searchParams.get('pdict') || 'combine'
  const tmode = searchParams.get('tmode') || 'qt_v1'

  return {
    pdict,
    tmode,
    ontab: 'batch',
    _title: 'Dịch đoạn văn',
    _meta: {
      left_nav: [{ text: 'Dịch nhanh', icon: 'languaeg', href: pathname }],
    },
  }
}) satisfies PageLoad
