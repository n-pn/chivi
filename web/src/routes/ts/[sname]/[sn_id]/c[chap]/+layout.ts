import { _pgidx } from '$lib/kit_path'
import { api_get } from '$lib/api_call'
import type { PageLoad } from './$types'

export const load = (async ({ params, parent, fetch, url }) => {
  const { crepo, _conf, _navs } = await parent()

  const { sn_id, sname } = params
  const ch_no = parseInt(params.chap)

  const rdurl = `/_rd/chaps/${sname}/${sn_id}/${ch_no}?force=${_conf._auto_}`
  const rdata = await api_get<CV.Chinfo>(rdurl, fetch)

  return {
    rdata,
    _show_conf: true,
    _meta: { title: `${rdata.title} - ${crepo.vname}` },
    _prev: { text: 'Mục lục', show: 'pl' },
    _curr: { text: `Ch#${ch_no}`, show: 'pm', kind: 'uname' },
    _navs: [..._navs, { href: url.pathname, text: rdata.title }],
  }
}) satisfies PageLoad
