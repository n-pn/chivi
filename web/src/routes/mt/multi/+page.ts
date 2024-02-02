import type { PageLoad } from './$types'

export const load = (async ({ url: { searchParams, pathname } }) => {
  return {
    input: (searchParams.get('zh') || '').trim(),
    pdict: searchParams.get('mt') || 'mtl_2',
    m_alg: searchParams.get('pd') || 'combine',
    ontab: 'multi',

    _title: 'Nhiều kết quả',
    _meta: {
      left_nav: [{ text: 'Nhiều kết quả', icon: 'bolt', href: pathname }],
    },
  }
}) satisfies PageLoad
