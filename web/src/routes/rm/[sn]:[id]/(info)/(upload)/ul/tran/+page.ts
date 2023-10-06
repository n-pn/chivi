import { nav_link } from '$utils/header_util'
import type { PageLoad } from './$types'

export const load = (async ({ parent }) => {
  const { ustem } = await parent()

  const _meta = {
    left_nav: [
      nav_link('.', ustem.vname, 'folder', { show: 'ts', kind: 'title' }),
      nav_link('data', 'Bản dịch', 'language'),
    ],
  }

  return {
    ontab: 'md',
    _title: `Đăng bản dịch có sẵn - ${ustem.vname}`,
    _meta,
  }
}) satisfies PageLoad
