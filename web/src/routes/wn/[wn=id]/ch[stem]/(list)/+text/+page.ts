import { book_nav, seed_nav, nav_link } from '$utils/header_util'

import { api_get } from '$lib/api_call'
import { _pgidx } from '$lib/kit_path'

type ZtextRaw = { ztext: string; title: string; chdiv: string }

export async function load({ url: { searchParams }, fetch, parent, params }) {
  const wn_id = parseInt(params.wn, 10)
  const sname = params.seed
  const ch_no = parseInt(searchParams.get('ch_no'), 10)

  const api_url = `/_wn/texts/${wn_id}/${sname}/${ch_no}`
  const { ztext, title, chdiv } = await api_get<ZtextRaw>(api_url, fetch)

  const { nvinfo } = await parent()

  const _title = `Thêm sửa đơn chương - ${nvinfo.vtitle}`
  const _meta = page_meta(nvinfo, sname, ch_no)

  return { ztext, title, chdiv, ch_no, wn_id, sname, _meta, _title }
}

function page_meta({ bslug, vtitle }, sname: string, ch_no: number) {
  const chap_url = `/wn/${bslug}/ch${sname}/${ch_no}`

  return {
    left_nav: [
      book_nav(bslug, vtitle, 'tm'),
      seed_nav(bslug, sname, _pgidx(ch_no), 'ts'),
      nav_link('+text', '', 'edit'),
    ],
    right_nav: [
      nav_link(chap_url, 'Hồi chương', 'arrow-back-up', { show: 'tm' }),
    ],
  }
}
