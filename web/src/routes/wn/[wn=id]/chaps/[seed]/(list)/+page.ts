import { api_get } from '$lib/api_call'
import type { PageLoad } from './$types'

export const load = (async ({ fetch, url, params }) => {
  const wn_id = parseInt(params.wn, 10)
  const pg_no = +url.searchParams.get('pg') || 1

  const api_url = `/_wn/chaps/${wn_id}/${params.seed}?pg=${pg_no}`

  const chaps = await api_get<CV.Wnchap[]>(api_url, fetch)

  const _title = 'Danh sách chương'
  const _board = `ns:${wn_id}:${params.seed}`

  return { chaps, pg_no, _title, _board }
}) satisfies PageLoad
