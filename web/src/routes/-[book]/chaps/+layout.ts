// export const ssr = false

import { get_nslist } from '$lib/api'
import { suggest_read } from '$utils/ubmemo_utils'

export async function load({ parent, fetch, url }) {
  const { nvinfo, ubmemo } = await parent()
  const nslist = await get_nslist(nvinfo.id, fetch)

  const _meta: App.PageMeta = {
    title: 'Chương tiết truyện ' + nvinfo.btitle_vi,
    // prettier-ignore
    left_nav: [
      { text: nvinfo.btitle_vi, icon: 'book', href: `/-${nvinfo.bslug}`, "data-show": 'tm', "data-kind": 'title' },
      { text: 'Chương tiết', icon: 'list', href: url.pathname, "data-show": 'pm' },
    ],
    right_nav: [suggest_read(nvinfo, ubmemo)],
  }

  return { nslist, _meta }
}
