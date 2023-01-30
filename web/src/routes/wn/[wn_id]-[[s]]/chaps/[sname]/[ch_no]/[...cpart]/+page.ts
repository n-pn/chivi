import { api_get } from '$lib/api_call'
import { api_chap_url } from './shared'

export interface ChapPart {
  curr_chap: CV.Chinfo
  //
  _prev_url: string | null
  _next_url: string | null
  ///
  chap_data: CV.Zhchap
}

export async function load({ params, fetch }) {
  const ch_no = +params.ch_no
  const cpart = +params.cpart.split('/')[1] || 1

  const path = api_chap_url(+params.wn_id, params.sname, ch_no, cpart, false)
  const data = await api_get<ChapPart>(path, fetch)

  return { ...data, cpart, redirect: params.cpart == '' }
}
