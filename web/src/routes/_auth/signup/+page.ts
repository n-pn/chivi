import { home_nav, nav_link } from '$gui/global/header_util'

import type { PageLoad } from './$types'

const _meta: App.PageMeta = {
  title: 'Quên mật khẩu',
  left_nav: [home_nav('ps'), nav_link('passwd', 'Quên mật khẩu', 'key')],
}

export const load = (({ url }) => {
  return { email: url.searchParams.get('email') || '', _meta }
}) satisfies PageLoad
