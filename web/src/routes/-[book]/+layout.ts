import { api_path } from '$lib/api_call'
import { suggest_read } from '$utils/ubmemo_utils'

import type { LayoutLoad } from './$types'
export const load: LayoutLoad = async ({ params, fetch }) => {
  const path = api_path('nvinfos.show', params.book)
  const data = await fetch(path).then((r) => r.json())
  const { nvinfo, ubmemo } = data

  data._meta = {
    title: `${nvinfo.btitle_vi}`,
    left_nav: [
      // prettier-ignore
      { text: nvinfo.btitle_vi, icon: 'book', href: `/-${nvinfo.bslug}`, "data-show": 'tm', "data-kind": 'title' },
    ],
    right_nav: [suggest_read(nvinfo, ubmemo)],
  } satisfies App.PageMeta

  return data
}
