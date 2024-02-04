import { load_ys_crits } from '$lib/fetch_data'

import type { PageLoad } from './$types'

export const load = (async ({ url, fetch, parent }) => {
  const { nvinfo } = await parent()

  const qdata = {
    sort: url.searchParams.get('sort') || 'utime',
    smin: +url.searchParams.get('smin') || 0,
    smax: +url.searchParams.get('smax') || 6,
    pg: +url.searchParams.get('pg') || 1,
  }

  let query = url.searchParams.toString() || 'sort=score'
  query += `&lm=10&book=${nvinfo.id}`
  return {
    ydata: await load_ys_crits(query, fetch),
    qdata,
    ontab: 'crits',
  }
}) satisfies PageLoad
