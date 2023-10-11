import { home_nav, nav_link } from '$utils/header_util'
import { api_get } from '$lib/api_call'
import type { PageLoad } from './$types'

interface Data extends CV.Paginate {
  items: Array<CV.Upstem>
}

const _title = 'Sưu tầm cá nhân'

const _meta = {
  left_nav: [
    home_nav('pl'),
    nav_link('/up', 'Sưu tầm cá nhân', 'album', { kind: 'title' }),
  ],
}

export const load = (async ({ url, fetch }) => {
  const query = {
    by: url.searchParams.get('by'),
    wn: url.searchParams.get('wn'),
    lb: url.searchParams.get('lb'),
    kw: url.searchParams.get('kw'),
  }

  const props = await api_get<Data>(`/_rd/upstems${url.search}`, fetch)

  return { props, query, _title, _meta, ontab: 'home' }
}) satisfies PageLoad
