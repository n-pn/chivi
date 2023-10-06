import type { PageLoad } from './$types'

import { nav_link } from '$utils/header_util'

export const load = (async ({ parent }) => {
  const { ustem, sroot } = await parent()

  const _meta = {
    left_nav: [
      nav_link(sroot, ustem.vname, 'file', { show: 'pl', kind: 'title' }),
      nav_link('ul', 'Quản lý', 'upload', { show: 'pm' }),
    ],
  }

  const _title = 'Quản lý nội dung - ' + ustem.vname
  return { _meta, _title, intab: 'su', ontab: 'cf' }
}) satisfies PageLoad
