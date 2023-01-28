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
  const cpart = +params.cpart.split('/').pop() || 1

  const path = api_chap_url(+params.wn_id, params.sname, ch_no, cpart, false)
  const data = await api_get<ChapPart>(path, null, fetch)

  // const _meta = page_meta(nvinfo, data.curr_chap.title, sname, s_bid, +ch_no)

  return { ...data, cpart, redirect: params.cpart == '' }
}
