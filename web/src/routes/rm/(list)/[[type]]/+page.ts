import { api_get } from '$lib/api_call'

import type { PageLoad } from './$types'

interface Data extends CV.Paginate {
  items: Array<CV.Rmstem>
}

export const load = (async ({ url, fetch, params: { type } }) => {
  const query = {
    wn: url.searchParams.get('wn'),
    lb: url.searchParams.get('lb'),
    bt: url.searchParams.get('bt'),
    by: url.searchParams.get('by'),
  }

  const rpath = `/rm/${type || ''}`

  const _navs: App.PageNavi[] = [
    {
      href: '/rm',
      text: 'Nguồn nhúng',
      icon: 'world',
      show: 'pl',
    },
  ]

  const search = new URLSearchParams(url.searchParams)
  if (type == 'liked') {
    search.append('_m', 'liked')
    _navs.push({ href: rpath, text: 'Đang theo dõi', icon: 'star' })
  } else if (type && type[0] == '!') {
    search.append('sn', type)
    _navs.push({ href: rpath, text: type, icon: 'folder', kind: 'zseed' })
    type = 'index'
  }

  const rdurl = `/_rd/rmstems?${search.toString()}`
  const props = await api_get<Data>(rdurl, fetch)
  return { props, query, ontab: type || 'index', rpath, _navs }
}) satisfies PageLoad
