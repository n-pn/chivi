import { nav_link } from '$utils/header_util'
import { api_get } from '$lib/api_call'
import type { PageLoad } from './$types'

export const load = (async ({ fetch, parent }) => {
  const { sroot, ustem } = await parent()
  let uform = { ...ustem }

  const _title = `Sửa thông tin - ${ustem.vname}`

  const _meta = {
    left_nav: [
      nav_link(sroot, ustem.vname, 'file', { show: 'pl', kind: 'title' }),
      nav_link('su', 'Sửa thông tin', 'ballpen', { show: 'pm' }),
    ],
  }

  return { uform, _meta, _title, intab: 'su', ontab: 'su' }
}) satisfies PageLoad

// export function load() {
//
//   return { nvinfo, wnform, _meta }
// }
