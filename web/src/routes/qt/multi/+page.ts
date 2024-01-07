import type { PageLoad } from './$types'

export const load = (async ({ url: { searchParams, pathname } }) => {
  const input = (searchParams.get('zh') || '').trim()
  const m_alg = searchParams.get('m_alg') || 'mtl_2'
  const pdict = searchParams.get('pdict') || 'combine'

  return {
    input,
    pdict,
    m_alg,
    ontab: 'multi',

    _title: 'Nhiều kết quả',
    _meta: {
      left_nav: [{ text: 'Nhiều kết quả', icon: 'bolt', href: pathname }],
    },
  }
}) satisfies PageLoad
