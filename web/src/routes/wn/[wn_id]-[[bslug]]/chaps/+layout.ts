import { api_get } from '$lib/api_call'

import { suggest_read } from '$utils/ubmemo_utils'

export interface SeedList {
  _main: CV.Chroot
  users: CV.Chroot[]
  backs: CV.Chroot[]
}

export async function load({ parent, fetch, url, depends, params }) {
  depends('wn:seed_list')

  const path = `/_wn/seeds?wn_id=${params.wn_id}`
  const seeds: SeedList = await api_get(path, null, fetch)

  const { nvinfo, ubmemo } = await parent()

  const _meta: App.PageMeta = {
    title: 'Chương tiết truyện ' + nvinfo.btitle_vi,
    // prettier-ignore
    left_nav: [
      { text: nvinfo.btitle_vi, icon: 'book', href: `/-${nvinfo.bslug}`, "data-show": 'tm', "data-kind": 'title' },
      { text: 'Chương tiết', icon: 'list', href: url.pathname, "data-show": 'pm' },
    ],
    right_nav: [suggest_read(nvinfo, ubmemo)],
  }

  return { seeds, _meta }
}
