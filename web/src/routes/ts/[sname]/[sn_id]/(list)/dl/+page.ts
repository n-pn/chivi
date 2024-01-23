import { nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

export const load = (async ({ parent }) => {
  const { crepo } = await parent()

  const _meta = {
    left_nav: [
      nav_link('.', crepo.vname, 'album', { show: 'ts', kind: 'title' }),
      nav_link('dl', 'Tải xuống', 'download'),
    ],
  }

  return {
    intab: 'rd',
    ontab: 'dl',
    _title: `Tải xuống - ${crepo.vname}`,
    _meta,
  }
}) satisfies PageLoad
