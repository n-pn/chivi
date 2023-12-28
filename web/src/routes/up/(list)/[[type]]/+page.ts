import { api_get } from '$lib/api_call'

import { home_nav, nav_link } from '$utils/header_util'
import type { PageLoad } from './$types'

interface Data extends CV.Paginate {
  items: Array<CV.Upstem>
}

const _title = 'Sưu tầm cá nhân'

const _meta = {
  left_nav: [home_nav(), nav_link('/up', 'Sưu tầm', 'album', { show: 'pm' })],
}

export const load = (async ({ url, fetch, params }) => {
  const query = {
    by: url.searchParams.get('by'),
    wn: url.searchParams.get('wn'),
    lb: url.searchParams.get('lb'),
    kw: url.searchParams.get('kw'),
  }

  let ontab = params.type || ''
  const search = new URLSearchParams(url.searchParams)

  if (ontab == 'liked') search.append('_m', 'liked')
  else if (ontab == 'owned') search.append('_m', 'owned')

  const rdurl = `/_rd/upstems?${search.toString()}`
  const props = await api_get<Data>(rdurl, fetch)

  return { props, query, _title, _meta, ontab }
}) satisfies PageLoad
