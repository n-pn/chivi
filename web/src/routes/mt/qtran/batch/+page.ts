import type { PageLoad } from './$types'

export const load = (async ({ url: { searchParams, pathname }, parent }) => {
  const pdict = searchParams.get('pd') || 'combine'
  const qkind = searchParams.get('mt') || 'qt_v1'

  const { _navs } = await parent()
  return {
    pdict,
    qkind,
    ontab: 'qbulk',
    _prev: { show: 'ts' },
    _navs: [..._navs, { text: 'Dịch văn bản', icon: 'language', href: pathname }],
    // _alts: [{ text: 'Nạp Vcoin', icon: 'coin', href: '/me/vcoin/+coin' }],
  }
}) satisfies PageLoad
