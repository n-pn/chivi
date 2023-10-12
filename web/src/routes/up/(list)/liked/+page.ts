import { api_get } from '$lib/api_call'

import { nav_link } from '$utils/header_util'
import type { PageLoad } from './$types'

interface Data extends CV.Paginate {
  items: Array<CV.Upstem>
}

const _title = 'Sưu tầm cá nhân'

const _meta = {
  left_nav: [
    nav_link('/up', 'Sưu tầm cá nhân', 'album', { show: 'pm', kind: 'title' }),
    nav_link('owned', 'Của bạn', 'at'),
  ],
}

export const load = (async ({ url, fetch }) => {
  const query = {
    by: url.searchParams.get('by'),
    wn: url.searchParams.get('wn'),
    lb: url.searchParams.get('lb'),
    kw: url.searchParams.get('kw'),
  }

  const search = new URLSearchParams(url.searchParams)
  search.append('_m', 'liked')

  const rdurl = `/_rd/upstems?${search.toString()}`
  const props = await api_get<Data>(rdurl, fetch)

  return { props, query, _title, _meta, ontab: 'like' }
}) satisfies PageLoad
