import { api_get, api_path, merge_query } from '$lib/api_call'
import type { PageData } from './$types'

export const load = (async ({ fetch, url }) => {
  const query = merge_query(url.searchParams, { lm: 10 })
  const path = api_path(`/_db/topics?${query.toString()}`)
  const dtlist = await api_get<CV.Dtlist>(path, fetch)

  return { dtlist }
}) satisfies PageData
