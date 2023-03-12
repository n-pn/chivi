import { api_get } from '$lib/api_call'

type ZtextRaw = { ztext: string; title: string; chdiv: string }

export async function load({ fetch, parent, params }) {
  const sname = params.sname
  const wn_id = +params.wn_id
  const ch_no = +params.ch_no

  const api_url = `/_wn/texts/${wn_id}/${sname}/${ch_no}`

  const { ztext, title, chdiv } = await api_get<ZtextRaw>(api_url, fetch)

  const { nvinfo } = await parent()
  const _meta = page_meta(nvinfo, sname, ch_no)

  return { ztext, title, chdiv, ch_no, wn_id, sname, _meta }
}

import { book_nav, seed_nav, nav_link } from '$gui/global/header_util'
import { _pgidx } from '$lib/kit_path'

function page_meta({ bslug, vtitle }, sname: string, ch_no: number) {
  return {
    title: `Sửa text gốc chương #${ch_no} - ${vtitle}`,
    left_nav: [
      book_nav(bslug, vtitle, 'tm'),
      seed_nav(bslug, sname, _pgidx(ch_no), 'ts'),
      nav_link('+edit', `Ch. ${ch_no}`, 'edit'),
    ],
    right_nav: [nav_link('-', `Chương`, 'arrow-back-up', { show: 'tm' })],
  }
}
