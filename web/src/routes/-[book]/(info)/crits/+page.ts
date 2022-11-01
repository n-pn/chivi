import { get_crits } from '$lib/ys_api'

export async function load({ fetch, parent, url }) {
  const sort = url.searchParams.get('sort') || 'score'

  const { nvinfo } = await parent()
  const opts = { book: nvinfo.id, take: 10, sort }

  return await get_crits(url.searchParams, opts, fetch)
}
