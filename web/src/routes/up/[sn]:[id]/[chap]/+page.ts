import { _pgidx } from '$lib/kit_path'
import { api_get } from '$lib/api_call'
import { nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

export const load = (async ({ url, parent, params, fetch }) => {
  const [ch_no, p_idx = 1] = params.chap.split('_').map((x) => parseInt(x))

  const rdata_api = `/_rd/chaps/up/${params.sn}/${params.id}/${ch_no}/${p_idx}`
  const rdata = await api_get<CV.Chpart>(rdata_api, fetch)

  const { ustem } = await parent()

  const ropts = get_ropts(ustem, rdata, url.searchParams)

  const _title = `${rdata.title} - ${ustem.vname}`
  // const _board = `ch:${book}:${chap}:${sname}`

  const _meta: App.PageMeta = {
    left_nav: [
      nav_link('.', ustem.vname, 'list', { show: 'pl', kind: 'title' }),
      nav_link('.', `Ch#${ch_no}`, '', { show: 'lg', kind: 'uname' }),
    ],
    show_config: true,
  }

  return { rdata, ropts, _meta, _title }
}) satisfies PageLoad

function get_ropts(ustem: CV.Upstem, { fpath }, params: URLSearchParams) {
  const wn_id = ustem.wninfo_id

  return {
    fpath,
    pdict: ustem.wndic && wn_id ? `book/${wn_id}` : `up/${ustem.id}`,
    wn_id: wn_id || 0,
    rtype: params.get('rm') || 'qt',
    qt_rm: params.get('qt') || 'qt_v1',
    mt_rm: params.get('mt') || 'mtl_1',
  }
}
