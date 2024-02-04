import { load_lists } from '$lib/fetch_data'

import type { PageLoad } from './$types'

export const load = (async ({ url, fetch, parent, params: { type } }) => {
  const { _user } = await parent()

  const new_url = new URL(url)
  if (type == 'owned') {
    new_url.searchParams.append('from', 'vi')
    new_url.searchParams.append('user', _user.uname)
  }

  const data = await load_lists(new_url, fetch)

  return {
    ...data,
    filter: { qs: url.searchParams.get('qs') },
    _meta: { title: 'Thư đơn truyện chữ' },
  }
}) satisfies PageLoad
