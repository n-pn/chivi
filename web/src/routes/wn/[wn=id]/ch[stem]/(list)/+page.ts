import { api_get } from '$lib/api_call'
import type { PageLoad } from './$types'

export const load = (async ({ fetch, url, params: { wn, stem } }) => {
  const wn_id = parseInt(wn, 10)
  const pg_no = +url.searchParams.get('pg') || 1

  const api_url = `/_wn/chaps/${wn_id}/${stem}?pg=${pg_no}`

  const chaps = await api_get<CV.Wnchap[]>(api_url, fetch)

  const _title = 'Danh sách chương'
  const _board = `ns:${wn_id}:${stem}`

  return { chaps, pg_no, _title, _board }
}) satisfies PageLoad
