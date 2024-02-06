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

  const { crepo, _navs } = await parent()
  const vname = crepo.vname || crepo.sroot

  return {
    zform,
    fixed: !!zform.ztext,
    ontab: 'ul',
    _meta: { title: `Đăng tải text gốc - ${vname}` },
    // _navs: [
    //   ..._navs,
    //   {
    //     href: '+text',
    //     text: 'Thêm text gốc',
    //     icon: 'upload',
    //   },
    // ],
  }
}) satisfies PageLoad
