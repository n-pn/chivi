import type { PageLoad } from './$types'

export const load = (async ({ url: { searchParams, pathname } }) => {
  const ztext = searchParams.get('zh') || ''
  const qkind = searchParams.get('mt') || 'mtl_2'
  const pdict = searchParams.get('pd') || 'combine'

  const batch_href = `/mt/qtran/batch?mt=${qkind}&pd=${pdict}`

  return {
    ztext,
    qkind,
    pdict,
    ontab: 'qtran',
    _prev: { show: 'ts' },
    _alts: [{ text: 'Dịch văn bản', icon: 'language', href: batch_href, show: 'ts' }],
  }
}) satisfies PageLoad
