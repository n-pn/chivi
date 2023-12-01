import { api_get } from '$lib/api_call'
import { _pgidx } from '$lib/kit_path'
import { nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

type ZtextRaw = { ztext: string; chdiv: string; ch_no: number }

export const load = (async ({ url, fetch, params, parent }) => {
  const { sname, sn_id } = params
  const ch_no = +url.searchParams.get('ch_no') || 0

  const rdurl = `/_rd/czdatas/${sname}/${sn_id}/${ch_no}`
  const zform = await api_get<ZtextRaw>(rdurl, fetch)

  const { sroot, crepo } = await parent()
  const vname = crepo.vname || crepo.sroot

  return {
    ...zform,
    ontab: 'ul',
    _title: `Đăng tải text gốc - ${vname}`,
    _meta: {
      left_nav: [
        nav_link(sroot, vname, 'article', { kind: 'title', show: 'pl' }),
        nav_link('ul', 'Thêm text', 'upload', { show: 'pm' }),
      ],
    },
  }
}) satisfies PageLoad
