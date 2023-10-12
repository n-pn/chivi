import { home_nav, nav_link } from '$utils/header_util'
import { api_get } from '$lib/api_call'
import type { PageLoad } from './$types'

interface Data extends CV.Paginate {
  items: Array<CV.Rmstem>
}

const _title = 'Nguồn liên kết nhúng'
const _meta = {
  left_nav: [
    home_nav(),
    nav_link('/rd', 'Nguồn nhúng', 'world', { kind: 'title' }),
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

  const props = await api_get<Data>(`/_rd/rmstems${url.search}`, fetch)

  return { props, query, _title, _meta, ontab: 'home' }
}) satisfies PageLoad
