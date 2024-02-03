import { api_get } from '$lib/api_call'

import type { PageLoad } from './$types'

interface DlTran {
  from_ch_no: number
  upto_ch_no: number

  init_word_count: number
  _flag: number
}

export const load = (async ({ fetch, url, params }) => {
  const { sname, sn_id } = params
  const pg_no = +url.searchParams.get('pg') || 1

  const path = `/_rd/dlcvs/${sname}/${sn_id}?pg=${pg_no}&lm=10`

  const dlcvs = await api_get<DlTran[]>(path, fetch)

  // const _meta = {
  //   desc: 'Tải xuống bản dịch bộ truyện',
  //   left_nav: [nav_link('+down', 'Tải bản dịch', 'pencil')],
  // }

  return { dlcvs, pg_no, _meta: { title: `Tải xuống nội dung` } }
}) satisfies PageLoad
