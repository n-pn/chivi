import { set_fetch, api_path, api_get } from '$lib/api_call'

import { suggest_read } from '$utils/ubmemo_utils'

export async function load({ parent, fetch, url }) {
  const { nvinfo, ubmemo } = await parent()
  set_fetch(fetch)

  const path = api_path('chroots.index', nvinfo.id)
  const nslist = await api_get(path)

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
