async function load_qdata(name: string, fetch: CV.Fetch) {
  let url: string
  const id = name.substring(2)
  if (name.startsWith('yc')) {
    url = `/_ys/crits/${id}/ztext`
  } else if (name.startsWith('yr')) {
    url = `/_ys/repls/${id}/ztext`
  } else {
    return ''
  }

  try {
    const res = await fetch(url)
    return await res.text()
  } catch (ex) {
    console.log(ex)
    return ex.message
  }
}

import type { PageLoad } from './$types'

export const load = (async ({ url: { searchParams }, fetch }) => {
  let pdict = searchParams.get('pd') || 'combine'
  let ztext = searchParams.get('zh') || ''

  const qt_id = searchParams.get('id') || ''
  if (qt_id) ztext = await load_qdata(qt_id, fetch)

  const qkind = searchParams.get('mt') || 'mtl_2'

  const batch_href = `/mt/qtran/batch?mt=${qkind}&pd=${pdict}`

  return {
    qt_id,
    ztext,
    qkind,
    pdict,
    ontab: 'qtran',
    _prev: { show: 'ts' },
    _alts: [{ text: 'Dịch văn bản', icon: 'language', href: batch_href, show: 'ts' }],
  }
}) satisfies PageLoad
