import { _pgidx } from '$lib/kit_path'
import { api_get } from '$lib/api_call'
import { nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

export const load = (async ({ url, parent, params, fetch }) => {
  const { rstem } = await parent()

  const up_id = +params.id
  const [ch_no, p_idx = 1] = params.chap.split('_').map((x) => parseInt(x))

  const rdata_api = `/_up/chaps/${up_id}/${ch_no}/${p_idx}`

  const rdata = await api_get<CV.Chpart>(rdata_api, fetch)
  const xargs = get_xargs(rstem, rdata, url)

  const _title = `${rdata.title} - ${rstem.btitle_vi || rstem.btitle_zh}`
  // const _board = `ch:${book}:${chap}:${sname}`

  const _meta: App.PageMeta = {
    left_nav: [
      nav_link('.', rstem.btitle_vi, 'list', { show: 'pl', kind: 'title' }),
      nav_link('.', `Ch#${ch_no}`, '', { show: 'lg', kind: 'uname' }),
    ],
    show_config: true,
  }

  return { rdata, xargs, _meta, _title }
}) satisfies PageLoad

function get_xargs(rstem: CV.Rmstem, { fpath }, { searchParams }) {
  const wn_id = rstem.wn_id || 0
  const pdict = wn_id ? `book/${wn_id}` : 'combine'

  const zpage = { fpath, pdict, wn_id }

  const param = {
    rm: searchParams.get('rm') || 'qt',
    qt: searchParams.get('qt') || 'qt_v1',
    mt: searchParams.get('mt') || 'mtl_1',
  }

  return { zpage, param }
}
