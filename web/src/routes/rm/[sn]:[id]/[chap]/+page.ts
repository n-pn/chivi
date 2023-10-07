import { _pgidx } from '$lib/kit_path'
import { api_get } from '$lib/api_call'
import { nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

export const load = (async ({ url, parent, params, fetch }) => {
  const [ch_no, p_idx = 1] = params.chap.split('_').map((x) => parseInt(x))

  const rdurl = `/_rd/chaps/rm/${params.sn}/${params.id}/${ch_no}/${p_idx}`
  const rdata = await api_get<CV.Chpart>(rdurl, fetch)

  const { rstem } = await parent()

  const ropts = get_ropts(rstem, rdata, url)

  const _title = `${rdata.title} - ${rstem.btitle_vi || rstem.btitle_zh}`
  // const _board = `ch:${book}:${chap}:${sname}`

  const _meta: App.PageMeta = {
    left_nav: [
      nav_link('.', rstem.btitle_vi, 'list', { show: 'pl', kind: 'title' }),
      nav_link('.', `Ch#${ch_no}`, '', { show: 'lg', kind: 'uname' }),
    ],
    show_config: true,
  }

  return { rdata, ropts, _meta, _title }
}) satisfies PageLoad

function get_ropts(rstem: CV.Rmstem, { fpath }, { searchParams }) {
  return {
    fpath,
    pdict: rstem.wn_id ? `book/${rstem.wn_id}` : 'combine',
    wn_id: rstem.wn_id || 0,
    rtype: searchParams.get('rm') || 'qt',
    qt_rm: searchParams.get('qt') || 'qt_v1',
    mt_rm: searchParams.get('mt') || 'mtl_1',
  }
}
