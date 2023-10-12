// import { api_get } from '$lib/api_call'
import { nav_link } from '$utils/header_util'
import type { PageLoad } from './$types'

const _meta: App.PageMeta = {
  left_nav: [
    nav_link('/rm', 'Nguồn nhúng', 'world', { show: 'pl' }),
    nav_link('/rm/+stem', 'Thêm mới', 'file-plus', { kind: 'title' }),
  ],
  right_nav: [],
}

export const load = (async ({ url: { searchParams }, fetch }) => {
  return { ontab: '+new', _meta, _title: 'Thêm nguồn nhung' }
}) satisfies PageLoad

// export function load() {
//
//   return { nvinfo, wnform, _meta }
// }
