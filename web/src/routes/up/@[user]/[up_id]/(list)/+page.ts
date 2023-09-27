import { api_get } from '$lib/api_call'
import type { PageLoad } from './$types'

export const load = (async ({ fetch, url: { searchParams }, params }) => {
  const pg_no = +searchParams.get('pg') || 1
  const api_url = `/_up/chaps/${+params.up_id}?pg=${pg_no}`

  const chaps = await api_get<CV.Wnchap[]>(api_url, fetch)
  const _title = 'Danh sách chương'

  return { chaps, pg_no, _title, ontab: 'ch' }
}) satisfies PageLoad
