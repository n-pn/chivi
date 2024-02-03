import { api_get } from '$lib/api_call'

import type { PageLoad } from './$types'

export const load = (async ({ fetch, url, params, parent, depends }) => {
  const { rstem, sroot } = await parent()
  depends(`rm:clist:${params.sn}:${params.id}`)

  const rdurl = `/_rd/chaps/rm${params.sn}/${params.id}`
  const chaps = await api_get<CV.Wnchap[]>(`${rdurl}?lm=4&_last=true`, fetch)

  const title = `${rstem.btitle_vi} - ${rstem.sname}`

  return { chaps, ontab: 'index', _meta: { title } }
}) satisfies PageLoad
