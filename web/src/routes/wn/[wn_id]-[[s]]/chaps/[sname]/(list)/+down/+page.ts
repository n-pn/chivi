import { api_get } from '$lib/api_call'
import type { PageLoad } from './$types'

interface DlTran {
  from_ch_no: number
  upto_ch_no: number

  init_word_count: number
  _flag: number
}

export const load = (async ({ fetch, url, params, depends }) => {
  depends('dlcvs')

  const pg_no = +url.searchParams.get('pg') || 1
  const api_url = `/_db/dlcvs?wn_id=${params.wn_id}&sname=?${params.sname}&pg=${pg_no}&lm=10`

  const dlcvs = await api_get<DlTran[]>(api_url, fetch)
  return { dlcvs, pg_no }
}) satisfies PageLoad
