import { api_get } from '$lib/api_call'
import { nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

export const load = (async ({ fetch, url, params, parent, depends }) => {
  const { rstem, sroot } = await parent()
  depends(`rm:clist:${params.sn}:${params.id}`)

  const rdurl = `/_rd/chaps/rm${params.sn}/${params.id}`
  const chaps = await api_get<CV.Wnchap[]>(`${rdurl}?lm=4&_last=true`, fetch)

  const _title = `${rstem.btitle_vi} - ${rstem.sname}`

  const _meta: App.PageMeta = {
    left_nav: [
      nav_link('/rm', 'Nguồn nhúng ngoài', 'file', { show: 'ts' }),
      nav_link(sroot, rstem.btitle_vi, 'list', { show: 'pl', kind: 'title' }),
    ],
  }

  return { chaps, _title, _meta, ontab: 'index' }
}) satisfies PageLoad
