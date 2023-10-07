import { api_get } from '$lib/api_call'
import type { PageLoad } from './$types'

export const load = (async ({ fetch, url, parent, params: { wn, stem } }) => {
  const wn_id = parseInt(wn, 10)
  const pg_no = +url.searchParams.get('pg') || 1

  const rdurl = `/_rd/chaps/wn/${stem}/${wn_id}`
  const chaps = await api_get<CV.Wnchap[]>(`${rdurl}?pg=${pg_no}`, fetch)
  const lasts = await api_get<CV.Wnchap[]>(`${rdurl}?lm=4&_last=true`, fetch)

  const { nvinfo } = await parent()

  const _title = `Danh sách chương - ${nvinfo.vtitle}`
  const _board = `ns:${wn_id}:${stem}`

  return { chaps, lasts, pg_no, _title, _board, ontab: 'ch' }
}) satisfies PageLoad
