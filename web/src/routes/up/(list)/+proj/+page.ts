import { api_get } from '$lib/api_call'

import { nav_link } from '$utils/header_util'
import type { PageLoad } from './$types'

const _meta: App.PageMeta = {
  left_nav: [
    nav_link('/up', 'Sưu tầm cá nhân', 'album', { show: 'pl' }),
    nav_link('/up/+proj', 'Thêm mới', 'file-plus', { kind: 'title' }),
  ],
  right_nav: [],
}

export const load = (async ({ url: { searchParams }, parent, fetch }) => {
  const { _user } = await parent()

  const uform = {
    id: 0,
    wn_id: +searchParams.get('wn') || 0,

    owner: _user.vu_id,
    sname: '@' + _user.uname,

    zname: '',
    vname: '',
    uslug: '',

    vintro: '',
    labels: [],

    guard: 0,
  }

  return { uform, ontab: '+new', _meta, _title: 'Tạo sưu tầm cá nhân' }
}) satisfies PageLoad

// export function load() {
//
//   return { nvinfo, wnform, _meta }
// }
