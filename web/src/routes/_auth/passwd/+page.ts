import type { PageLoad } from './$types'

import { home_nav, nav_link } from '$utils/header_util'

const _meta: App.PageMeta = {
  title: 'Đăng ký',
  left_nav: [home_nav('ps'), nav_link('signup', 'Đăng ký', 'user-plus')],
}

export const load = (({ url }) => {
  return { email: url.searchParams.get('email') || '', _meta }
}) satisfies PageLoad
