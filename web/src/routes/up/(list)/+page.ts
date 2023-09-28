import { home_nav, nav_link } from '$utils/header_util'
import { api_get } from '$lib/api_call'
import type { PageLoad } from './$types'

interface Data extends CV.Paginate {
  items: Array<CV.Upstem>
}

const _title = 'Dự án cá nhân'
const _meta = {
  left_nav: [
    home_nav('ps'),
    nav_link('/up', 'Dự án cá nhân', 'file', { show: 'pl' }),
  ],

  right_nav: [nav_link('/up/+proj', 'Tạo mới', 'file-plus', { kind: 'title' })],
}

export const load = (async ({ url, fetch }) => {
  const query = {
    by: url.searchParams.get('by'),
    wn: url.searchParams.get('wn'),
    lb: url.searchParams.get('lb'),
  }

  const props = await api_get<Data>(`/_up/stems${url.search}`, fetch)

  return { props, query, _title, _meta, ontab: 'list' }
}) satisfies PageLoad
