import type { PageLoad } from './$types'

export const load = (async ({ url: { searchParams, pathname } }) => {
  const input = (searchParams.get('zh') || '').trim()
  const pdict = searchParams.get('pdict') || 'combine'
  const m_alg = searchParams.get('m_alg') || 'mtl_2'

  return {
    input,
    pdict,
    m_alg,
    ontab: 'index',

    _title: 'Dịch nhanh',
    _meta: {
      left_nav: [{ text: 'Dịch nhanh', icon: 'bolt', href: pathname }],
    },
  }
}) satisfies PageLoad
