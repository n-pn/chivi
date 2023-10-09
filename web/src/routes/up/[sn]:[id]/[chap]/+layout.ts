import { _pgidx } from '$lib/kit_path'
import { api_get } from '$lib/api_call'
import { nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

export const load = (async ({ parent, params, fetch }) => {
  const [ch_no, p_idx = 1] = params.chap.split('_').map((x) => parseInt(x))

  const rdurl = `/_rd/chaps/up/${params.sn}/${params.id}/${ch_no}/${p_idx}`
  const rdata = await api_get<CV.Chpart>(rdurl, fetch)

  const { ustem } = await parent()
  const _title = `${rdata.title} - ${ustem.vname}`
  // const _board = `ch:${book}:${chap}:${sname}`

  const _meta: App.PageMeta = {
    left_nav: [
      nav_link('.', ustem.vname, 'list', { show: 'pl', kind: 'title' }),
      nav_link('.', `Ch#${ch_no}`, '', { show: 'lg', kind: 'uname' }),
    ],
    show_config: true,
  }

  return { rdata, _meta, _title }
}) satisfies PageLoad
