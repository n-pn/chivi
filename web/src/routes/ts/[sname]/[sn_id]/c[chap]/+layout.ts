import { _pgidx } from '$lib/kit_path'
import { api_get } from '$lib/api_call'
import { nav_link } from '$utils/header_util'
import type { PageLoad } from './$types'

const parse_chid = ({ chap }) => chap.split('_').map((x) => parseInt(x))

export const load = (async ({ params, parent, fetch }) => {
  const { crepo, _conf, sroot } = await parent()

  const { sn_id, sname } = params
  const [ch_no, p_idx = 1] = parse_chid(params)

  const rdurl = `/_rd/chaps/${sname}/${sn_id}/${ch_no}/${p_idx}?force=${_conf.auto_u}`
  const rdata = await api_get<CV.Chpart>(rdurl, fetch)

  const { vname } = crepo
  const _title = `${rdata.title} - ${vname}`

  const _meta: App.PageMeta = {
    left_nav: [
      nav_link(sroot, vname, 'list', { kind: 'title', show: 'pl' }),
      nav_link('.', `Ch#${ch_no}`, '', { show: 'lg', kind: 'uname' }),
    ],
  }

  return { rdata, _meta, _title }
}) satisfies PageLoad
