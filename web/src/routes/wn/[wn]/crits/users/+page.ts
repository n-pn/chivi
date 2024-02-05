import type { PageLoad } from './$types'
import { load_vi_crits } from '$lib/fetch_data'

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
    vdata: await load_vi_crits(query, fetch),
    qdata,
    ontab: 'crits',
  }
}) satisfies PageLoad
