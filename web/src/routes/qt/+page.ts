import type { PageLoad } from './$types'

export const load = (async ({ url: { searchParams, pathname } }) => {
  const input = (searchParams.get('zh') || '').trim()
  const pdict = searchParams.get('pdict') || 'combine'
  const m_alg = searchParams.get('m_alg') || 'mtl_2'

  const _meta: App.PageMeta = {
    left_nav: [{ text: 'Dịch nhanh', icon: 'bolt', href: pathname }],
  }

  return { input, pdict, m_alg, _meta, _title: 'Dịch nhanh', ontab: 'sent' }
}) satisfies PageLoad
