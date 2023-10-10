import { _pgidx } from '$lib/kit_path'
import { api_get } from '$lib/api_call'
import { seed_nav, nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

export const load = (async ({ url, parent, params, fetch }) => {
  const { nvinfo, _conf } = await parent()

  const wn_id = parseInt(params.wn, 10)
  const sname = params.stem

  const [ch_no, p_idx = 1] = params.chap.split('_').map((x) => parseInt(x))

  const force = _conf.auto_u
  const rdurl = `/_rd/chaps/wn/${sname}/${wn_id}/${ch_no}/${p_idx}?force=${force}`
  const rdata = await api_get<CV.Chpart>(rdurl, fetch)

  const _title = `${rdata.title} - ${nvinfo.btitle_vi}`
  // const _board = `ch:${book}:${chap}:${sname}`

  const _meta: App.PageMeta = {
    left_nav: [
      seed_nav(nvinfo.bslug, sname, _pgidx(ch_no), 'ts'),
      // nav_link('.', nvinfo.btitle_vi, 'list', { show: 'pl', kind: 'title' }),
      nav_link('.', `Ch#${ch_no}`, '', { show: 'lg', kind: 'uname' }),
    ],
    show_config: true,
  }

  return { rdata, _meta, _title }
}) satisfies PageLoad

function get_ropts(wn_id: number, { fpath }, params: URLSearchParams) {
  return {
    fpath,
    pdict: `book/${wn_id}`,
    wn_id: wn_id,
    rtype: params.get('rm') || 'qt',
    qt_rm: params.get('qt') || 'qt_v1',
    mt_rm: params.get('mt') || 'mtl_1',
  }
}
