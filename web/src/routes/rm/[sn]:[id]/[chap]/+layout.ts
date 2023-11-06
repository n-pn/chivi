import { _pgidx } from '$lib/kit_path'
import { api_get } from '$lib/api_call'
import { nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

export const load = (async ({ parent, params, fetch }) => {
  const { rstem, _conf } = await parent()

  const [ch_no, p_idx = 1] = params.chap.split('_').map((x) => parseInt(x))
  const force = _conf.auto_u

  const rdurl = `/_rd/chaps/rm/${params.sn}/${params.id}/${ch_no}/${p_idx}?force=${force}`
  const rdata = await api_get<CV.Chpart>(rdurl, fetch)

  const _title = `${rdata.title} - ${rstem.btitle_vi || rstem.btitle_zh}`
  // const _board = `ch:${book}:${chap}:${sname}`

  const _meta: App.PageMeta = {
    left_nav: [
      nav_link('.', rstem.btitle_vi, 'list', { show: 'pl', kind: 'title' }),
      nav_link('.', `Ch#${ch_no}`, '', { show: 'lg', kind: 'uname' }),
    ],
  }

  return { rdata, _meta, _title }
}) satisfies PageLoad