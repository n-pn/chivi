import { nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

export const load = (async ({ parent }) => {
  const { rstem } = await parent()

  const _meta = {
    left_nav: [
      nav_link('.', rstem.btitle_vi, 'folder', { show: 'ts', kind: 'title' }),
      nav_link('bants', 'Thảo luận', 'download'),
    ],
  }

  return {
    ontab: 'bants',
    _title: `Thảo luận - ${rstem.btitle_vi}`,
    _meta,
  }
}) satisfies PageLoad
