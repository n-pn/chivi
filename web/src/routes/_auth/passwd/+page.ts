import { home_nav, nav_link } from '$utils/header_util'
import type { PageLoad } from './$types'

const _meta: App.PageMeta = {
  left_nav: [home_nav('ps'), nav_link('paswrd', 'Đổi mật khẩu', 'key')],
}

export const load = (({ url }) => {
  const email = url.searchParams.get('email') || ''
  return { email, _meta, _title: 'Đổi mật khẩu' }
}) satisfies PageLoad
