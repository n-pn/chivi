import { seed_url, to_pgidx } from '$utils/route_utils'

import { api_get } from '$lib/api_call'
import { api_chap_url } from './shared'

export async function load({ params, parent, fetch }) {
  const [sname, s_bid = params.wn_id] = params.sname.split(':')
  const ch_no = +params.ch_no
  const cpart = +params.cpart || 1

  const path = api_chap_url(sname, +s_bid, ch_no, cpart, false)
  const data = await api_get<ChapPart>(path, null, fetch)

  const { nvinfo } = await parent()
  const _meta = page_meta(nvinfo, data._chap.title, sname, +ch_no)

  return { ...data, cpart, _meta, redirect: params.cpart == '' }
}

export interface ChapPart {
  ztext: string
  _chap: CV.Chinfo
  _prev: string | null
  _next: string | null
}

function page_meta(
  nvinfo: CV.Nvinfo,
  title: string,
  sname: string,
  ch_no: number
): App.PageMeta {
  let list_url = `/wn/${nvinfo.bslug}/chaps/${sname}`
  if (ch_no > 32) list_url += '?pg=' + to_pgidx(ch_no)

  if (sname == '_') sname = 'Tổng hợp'

  return {
    title: `${title} - ${nvinfo.btitle_vi}`,
    left_nav: [
      {
        'text': nvinfo.btitle_vi,
        'href': `/wn/${nvinfo.bslug}`,
        'data-kind': 'title',
        'data-show': 'pl',
      },
      { 'text': sname, 'icon': 'list', 'href': list_url, 'data-kind': 'zseed' },
    ],
    show_config: true,
  }
}
