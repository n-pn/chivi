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

  const wn_id = parseInt(params.wn, 10)
  const pg_no = +url.searchParams.get('pg') || 1

  const path = `/_db/dlcvs?wn_id=${wn_id}&sname=${params.seed}&pg=${pg_no}&lm=10`

  const dlcvs = await api_get<DlTran[]>(path, fetch)
  const { nvinfo } = await parent()

  const _meta = {
    desc: 'Tải xuống bản dịch bộ truyện',
    left_nav: [
      book_nav(nvinfo.id, nvinfo.vtitle, 'tm'),
      nav_link('+down', 'Tải bản dịch', 'pencil'),
    ],
  }

  return {
    dlcvs,
    pg_no,
    _meta,
    _title: `Tải xuống bản dịch truyện: ${nvinfo.vtitle}`,
  }
}) satisfies PageLoad
