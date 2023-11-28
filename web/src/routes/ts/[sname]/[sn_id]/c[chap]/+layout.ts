import { _pgidx } from '$lib/kit_path'
import { api_get } from '$lib/api_call'
import { seed_nav, nav_link } from '$utils/header_util'
import type { PageLoad } from './$types'

const gen_pdict = ({ stype, wn_id, sn_id }) => {
  if (wn_id > 0) return `book/${wn_id}`
  if (stype == 1) return `up/${sn_id}`
  return 'combine'
}

const parse_chid = ({ chap }) => chap.split('_').map((x) => parseInt(x))

export const load = (async ({ params, parent, fetch }) => {
  const [ch_no, p_idx = 1] = parse_chid(params)

  const { crepo, _conf } = await parent()
  const rdurl = `/_rd/chaps/${crepo.sroot}/${ch_no}/${p_idx}?force=${_conf.auto_u}`
  const rdata = await api_get<CV.Chpart>(rdurl, fetch)

  const _title = `${rdata.title} - ${crepo.vname}`

  const _meta: App.PageMeta = {
    left_nav: [
      seed_nav(crepo.sroot, crepo.vname, _pgidx(ch_no), 'ts'),
      nav_link('.', `Ch#${ch_no}`, '', { show: 'lg', kind: 'uname' }),
    ],
  }

  return { rdata, _meta, _title }
}) satisfies PageLoad
