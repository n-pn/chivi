import { api_get } from '$lib/api_call'

import { nav_link } from '$utils/header_util'
import type { PageLoad } from './$types'

interface Data extends CV.Paginate {
  items: Array<CV.Rmstem>
}

const _title = 'Nguồn liên kết nhúng'

const _meta = {
  left_nav: [
    nav_link('/rm', 'Nguồn nhúng', 'world', { kind: 'title', show: 'pl' }),
    nav_link('liked', 'Đang theo dõi', 'star'),
  ],
}

export const load = (async ({ url, fetch }) => {
  const query = {
    wn: url.searchParams.get('wn'),
    sn: url.searchParams.get('sn'),
    lb: url.searchParams.get('lb'),
    bt: url.searchParams.get('bt'),
    by: url.searchParams.get('by'),
  }

  const search = new URLSearchParams(url.searchParams)
  search.append('_m', 'liked')

  const rdurl = `/_rd/rmstems?${search.toString()}`
  const props = await api_get<Data>(rdurl, fetch)

  return { props, query, _title, _meta, ontab: 'like' }
}) satisfies PageLoad
