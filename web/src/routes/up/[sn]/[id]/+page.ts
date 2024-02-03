import { api_get } from '$lib/api_call'

import type { PageLoad } from './$types'

export const load = (async ({ fetch, url, params, parent }) => {
  const rdurl = `/_rd/chaps/up${params.sn}/${params.id}`

  const chaps = await api_get<CV.Wnchap[]>(`${rdurl}?lm=4&_last=true`, fetch)

  const { ustem, sroot } = await parent()

  // const _meta: App.PageMeta = {
  //   left_nav: [
  //     nav_link('/up', 'Sưu tầm', 'album', { show: 'pl' }),
  //     nav_link(sroot, ustem.vname, 'book', { kind: 'title' }),
  //   ],
  // }

  return {
    chaps,
    ontab: 'index',
    _meta: { title: `Sưu tầm của ${ustem.sname}: ${ustem.vname}` },
    // _navs: {},
  }
}) satisfies PageLoad
