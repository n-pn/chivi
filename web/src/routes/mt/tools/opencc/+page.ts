import { home_nav, nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

const _meta: App.PageMeta = {
  left_nav: [
    home_nav('ts'),
    nav_link('/mt/tools/opencc', 'Phồn -> Giản', 'arrows-shuffle'),
  ],
}

export const load = (({ url }) => {
  const _mode = url.searchParams.get('_mode') || 'hk2s'

  const _mdesc = 'Chuyển đổi từ phồn thể sang giản thể'
  return { _mode, _meta, _title: 'Phồn -> Giản', _mdesc }
}) satisfies PageLoad
