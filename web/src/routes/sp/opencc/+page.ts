import { home_nav, nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

const _meta: App.PageMeta = {
  left_nav: [
    home_nav('ts'),
    nav_link('/sp/opencc', 'Phồn -> Giản', 'arrows-shuffle'),
  ],
}

export const load = (({ url }) => {
  const config = url.searchParams.get('config') || 'hk2s'
  const _mdesc = 'Chuyển đổi từ phồn thể sang giản thể'
  return { config, _meta, _title: 'Phồn -> Giản', _mdesc }
}) satisfies PageLoad
