import { api_get } from '$lib/api_call'
import type { PageLoad } from './$types'

export const load = (async ({ url, fetch, parent, params }) => {
  const { sname, sn_id } = params
  const pg_no = +url.searchParams.get('pg') || 1

  const rdurl = `/_rd/chaps/${sname}/${parseInt(sn_id)}`
  const chaps = await api_get<CV.Wnchap[]>(`${rdurl}?pg=${pg_no}`, fetch)
  const lasts = await api_get<CV.Wnchap[]>(`${rdurl}?lm=4&_last=true`, fetch)

  const { crepo } = await parent()
  const _title = `Danh sách chương - ${crepo.vname}`

  return { chaps, lasts, pg_no, _title, ontab: 'ch' }
}) satisfies PageLoad
