import { api_get } from '$lib/api_call'

import type { PageLoad } from './$types'

interface Data extends CV.Paginate {
  items: Array<CV.Upstem>
}

export const load = (async ({ url, fetch, params, parent }) => {
  let { _navs } = await parent()
  const query = {
    vu: url.searchParams.get('vu'),
    au: url.searchParams.get('au'),
    wn: url.searchParams.get('wn'),
    lb: url.searchParams.get('lb'),
    kw: url.searchParams.get('kw'),
  }

  let ontab = params.type || ''
  const search = new URLSearchParams(url.searchParams)

  if (ontab == 'owned') {
    search.append('_m', ontab)
    _navs = [
      ..._navs,
      {
        href: `/up/${ontab}`,
        text: 'Của bạn',
        icon: 'ballpen',
      },
    ] as App.PageNavi[]
  } else if (ontab[0] == '@') {
    search.append('vu', ontab.substring(1))
    _navs = [
      ..._navs,
      {
        href: `/up/${ontab}`,
        text: ontab,
        icon: 'at',
      },
    ] as App.PageNavi[]

    ontab = ''
  }

  const rdurl = `/_rd/upstems?${search.toString()}`
  const props = await api_get<Data>(rdurl, fetch)

  return { props, query, ontab, _navs }
}) satisfies PageLoad
