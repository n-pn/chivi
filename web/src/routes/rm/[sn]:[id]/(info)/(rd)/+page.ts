import { api_get } from '$lib/api_call'
import { nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

export const load = (async ({ fetch, url, params, parent, depends }) => {
  const { rstem, sroot } = await parent()
  depends(`rm:clist:${params.sn}:${params.id}`)

  const pg_no = +url.searchParams.get('pg') || 1
  const rdurl = `/_rd/chaps/rm/${params.sn}/${params.id}`

  const chaps = await api_get<CV.Wnchap[]>(`${rdurl}?pg=${pg_no}`, fetch)
  const lasts = await api_get<CV.Wnchap[]>(`${rdurl}?lm=4&_last=true`, fetch)

  const _title = `Liên kết ${rstem.sname} - ${rstem.btitle_vi}`

  const _meta: App.PageMeta = {
    left_nav: [
      nav_link('/rm', 'Nguồn nhúng ngoài', 'file', { show: 'ts' }),
      nav_link(sroot, rstem.btitle_vi, 'list', { show: 'pl', kind: 'title' }),
    ],
  }

  return { chaps, lasts, pg_no, sroot, _title, _meta, intab: 'rd', ontab: 'ch' }
}) satisfies PageLoad
