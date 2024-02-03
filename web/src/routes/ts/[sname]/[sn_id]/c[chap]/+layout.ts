import { _pgidx } from '$lib/kit_path'
import { api_get } from '$lib/api_call'
import type { PageLoad } from './$types'

const parse_chid = ({ chap }) => chap.split('_').map((x) => parseInt(x))

export const load = (async ({ params, parent, fetch, url }) => {
  const { crepo, _conf, _navs } = await parent()

  const { sn_id, sname } = params
  const [ch_no, p_idx = 1] = parse_chid(params)

  const rdurl = `/_rd/chaps/${sname}/${sn_id}/${ch_no}/${p_idx}?force=${_conf.auto_u}`
  const rdata = await api_get<CV.Chpart>(rdurl, fetch)

  return {
    rdata,
    _show_conf: true,
    _meta: { title: `${rdata.title} - ${crepo.vname}` },
    _navs: [
      ..._navs,
      {
        href: url.pathname,
        text: rdata.chdiv ? `${rdata.chdiv} - ${rdata.title}` : rdata.title,
        hd_text: `Ch#${ch_no}`,
        hd_show: 'pm',
        hd_kind: 'uname',
      },
    ],
  }
}) satisfies PageLoad
