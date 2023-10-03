import { _pgidx } from '$lib/kit_path'
import { api_get } from '$lib/api_call'
import { seed_nav, nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

export const load = (async ({ url, parent, params, fetch }) => {
  const wn_id = parseInt(params.wn, 10)
  const sname = params.stem

  const [ch_no, p_idx = 1] = params.chap.split('_').map((x) => parseInt(x))

  const rdata_api = `/_wn/chaps/${wn_id}/${sname}/${ch_no}/${p_idx}`

  const rdata = await api_get<CV.Chpart>(rdata_api, fetch)
  const xargs = get_xargs(wn_id, rdata, url)

  const { nvinfo } = await parent()
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

  return { rdata, xargs, _meta, _title }
}) satisfies PageLoad

function get_xargs(wn_id: number, { fpath }, { searchParams }) {
  const pdict = `book/${wn_id}`
  const zpage = { fpath, pdict, wn_id }
  const rtype = searchParams.get('rm') || 'qt'

  switch (rtype) {
    case 'qt':
      return { zpage, rtype, rmode: searchParams.get('qt') || 'qt_v1' }

    default:
      return { zpage, rtype: 'mt', rmode: searchParams.get('mt') || 'mtl_1' }
  }
}
