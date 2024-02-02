import { api_get } from '$lib/api_call'

import type { PageLoad } from './$types'

export const load = (async ({ fetch, url, params, parent, depends }) => {
  const { rstem, sroot } = await parent()
  depends(`rm:clist:${params.sn}:${params.id}`)

  const rdurl = `/_rd/chaps/rm${params.sn}/${params.id}`
  const chaps = await api_get<CV.Wnchap[]>(`${rdurl}?lm=4&_last=true`, fetch)

  const title = `${rstem.btitle_vi} - ${rstem.sname}`

  const _navs = [
    {
      href: '/rm',
      text: 'Nguồn nhúng',
    },
    {
      href: `/rm/${params.sn}`,
      text: params.sn,
      hd_icon: 'world',
      hd_show: 'pl',
      hd_kind: 'zseed',
    },
    {
      href: url.pathname,
      text: rstem.btitle_vi,
      hd_icon: 'book',
      hd_show: 'pl',
      hd_kind: 'title',
    },
  ]

  return { chaps, ontab: 'index', _navs, _meta: { title } }
}) satisfies PageLoad
