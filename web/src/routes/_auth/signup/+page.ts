import { home_nav, nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

const _meta: App.PageMeta = {
  title: 'Tạo tài khoản',
  left_nav: [home_nav('ps'), nav_link('signup', 'Tạo tài khoản', 'user-plus')],
}

export const load = (({ url }) => {
  return { email: url.searchParams.get('email') || '', _meta }
}) satisfies PageLoad
