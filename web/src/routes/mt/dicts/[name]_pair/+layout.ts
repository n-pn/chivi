import { api_get } from '$lib/api_call'

import type { LayoutLoad } from './$types'

export interface DictData {
  dinfo: CV.Zvdict
  users: string[]
  // terms: CV.Viterm[]
}

export const load = (async ({ fetch, params: { name }, url }) => {
  const { dinfo, users } = await api_get<DictData>(`/_sp/dicts/${name}_pair`, fetch)
  return {
    dinfo,
    users,
    _navs: [
      { href: '/mt/dicts', text: 'Từ điển', icon: 'package', show: 'ts' },
      { href: url.pathname, text: dinfo.label, icon: 'list', kind: 'title' },
    ],
  }
}) satisfies LayoutLoad
