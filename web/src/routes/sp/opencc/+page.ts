import { home_nav, nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

const _meta: App.PageMeta = {
  title: 'Phồn -> Giản',
  desc: 'Chuyển đổi từ phồn thể sang giản thể',
  left_nav: [
    home_nav('ts'),
    nav_link('/sp/opencc', 'Phồn -> Giản', 'arrows-shuffle'),
  ],
}

export const load = (({ url }) => {
  const config = url.searchParams.get('config') || 'hk2s'
  return { config, _meta }
}) satisfies PageLoad
