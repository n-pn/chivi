import { api_get } from '$lib/api_call'
import { seed_path } from '$lib/kit_path'
import { api_chap_url } from './shared'

export async function load({ params, parent, fetch }) {
  const [sname, s_bid = params.wn_id] = params.sname.split(':')
  const ch_no = +params.ch_no
  const cpart = +params.cpart.split('/').pop() || 1

  const path = api_chap_url(sname, +s_bid, ch_no, cpart, false)
  const data = await api_get<ChapPart>(path, null, fetch)

  const { nvinfo } = await parent()

  const _meta = page_meta(nvinfo, data.curr_chap.title, sname, s_bid, +ch_no)
  return { ...data, cpart, _meta, redirect: params.cpart == '' }
}

export interface ChapPart {
  curr_chap: CV.Chinfo
  //
  _prev_url: string | null
  _next_url: string | null
  ///
  ztext: string
  mtlv1: string
}

function page_meta(
  nvinfo: CV.Nvinfo,
  title: string,
  sname: string,
  s_bid: string | number,
  ch_no: number
): App.PageMeta {
  const list_url = seed_path(nvinfo.bslug, sname, s_bid, ch_no)
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
