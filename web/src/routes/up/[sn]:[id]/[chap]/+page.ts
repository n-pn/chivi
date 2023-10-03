import { _pgidx, stem_path } from '$lib/kit_path'
import { api_get } from '$lib/api_call'
import { nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

export const load = (async ({ url, parent, params, fetch }) => {
  const { ustem } = await parent()

  const up_id = +params.id
  const [ch_no, p_idx = 1] = params.chap.split('_').map((x) => parseInt(x))

  const rdata_api = `/_up/chaps/${up_id}/${ch_no}/${p_idx}`

  const rdata = await api_get<CV.Chpart>(rdata_api, fetch)
  const xargs = get_xargs(ustem, rdata, url)

  const _title = `${rdata.title} - ${ustem.vname}`
  // const _board = `ch:${book}:${chap}:${sname}`

  const _meta: App.PageMeta = {
    left_nav: [
      nav_link('.', ustem.vname, 'list', { show: 'pl', kind: 'title' }),
      nav_link('.', `Ch#${ch_no}`, '', { show: 'lg', kind: 'uname' }),
    ],
    show_config: true,
  }

  return { rdata, xargs, _meta, _title }
}) satisfies PageLoad

function get_xargs(ustem: CV.Upstem, { fpath }, { searchParams }) {
  const wn_id = ustem.wninfo_id || 0
  const pdict = ustem.wndic ? `book/${wn_id}` : `up/${ustem.id}`
  const zpage = { fpath, pdict, wn_id }

  const rtype = searchParams.get('rm') || 'qt'

  switch (rtype) {
    case 'qt':
      return { zpage, rtype, rmode: searchParams.get('qt') || 'qt_v1' }

    default:
      return { zpage, rtype: 'mt', rmode: searchParams.get('mt') || 'mtl_1' }
  }
}
