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

  if (!data.chap_data.cvmtl && data.chap_data.grant) {
    const ztext = data.chap_data.ztext
    data.chap_data.cvmtl = await get_cvdata(fetch, params.wn_id, ztext)
  }
  return { ...data, cpart, redirect: params.cpart == '' }
}

async function get_cvdata(fetch: CV.Fetch, wn_id: string, body: string) {
  const url = `http://localhost:5010/_db/cv_chap?wn_id=${wn_id}&cv_title=first`
  // const headers = { 'Content-Type': 'text/plain' }
  const res = await fetch(url, { method: 'POST', body })

  if (!res.ok) return ''
  return await res.text()
}
