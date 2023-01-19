import { api_path, api_get, set_fetch } from '$lib/api_call'
import { suggest_read } from '$utils/ubmemo_utils'

import type { LayoutLoad } from './$types'
export const load: LayoutLoad = async ({ params, fetch }) => {
  set_fetch(fetch)
  const path = api_path('nvinfos.show', params.book)
  const data = (await api_get(path)) as { nvinfo: CV.Nvinfo; ubmemo: CV.Ubmemo }

  const { nvinfo, ubmemo } = data

  const _meta = {
    title: `${nvinfo.btitle_vi}`,
    left_nav: [
      // prettier-ignore
      { text: nvinfo.btitle_vi, icon: 'book', href: `/-${nvinfo.bslug}`, "data-show": 'tm', "data-kind": 'title' },
    ],
    right_nav: [suggest_read(nvinfo, ubmemo)],
  } satisfies App.PageMeta

  return { ...data, _meta }
}
