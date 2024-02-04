import type { PageLoad } from './$types'
import { load_crits } from '$lib/fetch_data'

export const load = (async ({ url, fetch, params: { user } }) => {
  const qdata = {
    by: user,
    og: 'chivi',
    gt: +url.searchParams.get('gt') || 1,
    lt: +url.searchParams.get('lt') || 5,
    pg: +url.searchParams.get('pg') || 1,
    _s: url.searchParams.get('_s') || 'utime',
    _m: url.searchParams.get('_s'),
  }

  const title = `Đánh giá truyện chữ của @${user}`
  const query = (url.search || '?_s=utime') + `&lm=8&by=${user}`
  console.log(query)

  const { vdata, ydata } = await load_crits('chivi', query, fetch)
  return { vdata, ydata, qdata, ontab: 'crits', _meta: { title } }
}) satisfies PageLoad
