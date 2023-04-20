import { api_get } from '$lib/api_call'
import type { PageLoad } from './$types'

export const load = (async ({ fetch, url, params }) => {
  const pg_no = +url.searchParams.get('pg') || 1
  const api_url = `/_wn/chaps/${params.wn_id}/${params.seed}?pg=${pg_no}`

  const chaps = await api_get<CV.Chinfo[]>(api_url, fetch)
  return { chaps, pg_no }
}) satisfies PageLoad
