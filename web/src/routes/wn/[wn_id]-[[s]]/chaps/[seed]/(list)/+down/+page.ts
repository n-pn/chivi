import { api_get } from '$lib/api_call'
import { home_nav, nav_link, book_nav } from '$utils/header_util'

import type { PageLoad } from './$types'

interface DlTran {
  from_ch_no: number
  upto_ch_no: number

  init_word_count: number
  _flag: number
}

export const load = (async ({ fetch, url, params, depends, parent }) => {
  depends('dlcvs')
  const { nvinfo } = await parent()

  const pg_no = +url.searchParams.get('pg') || 1
  const api_url = `/_db/dlcvs?wn_id=${params.wn_id}&sname=${params.seed}&pg=${pg_no}&lm=10`

  const dlcvs = await api_get<DlTran[]>(api_url, fetch)

  const _meta = {
    title: `Tải xuống bản dịch truyện: ${nvinfo.vtitle}`,
    desc: 'Tải xuống bản dịch bộ truyện',
    left_nav: [
      home_nav('', ''),
      book_nav(nvinfo.bslug, nvinfo.vtitle, 'tm'),
      nav_link('+down', 'Tải bản dịch', 'pencil'),
    ],
  }

  return { dlcvs, pg_no, _meta }
}) satisfies PageLoad
