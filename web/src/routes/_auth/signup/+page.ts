import { home_nav, nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

const _meta: App.PageMeta = {
  left_nav: [home_nav('ps'), nav_link('signup', 'Tạo tài khoản', 'user-plus')],
}

export const load = (({ url }) => {
  const email = url.searchParams.get('email') || ''
  return { email, _meta, _title: 'Tạo tài khoản' }
}) satisfies PageLoad
