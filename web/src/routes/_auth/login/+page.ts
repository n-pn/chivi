import { home_nav, nav_link } from '$utils/header_util'
import type { PageLoad } from './$types'

const _meta: App.PageMeta = {
  left_nav: [home_nav('ps'), nav_link('login', 'Đăng nhập', 'login')],
}

export const load = (({ url }) => {
  const email = url.searchParams.get('email') || ''
  return { email, _meta, _title: 'Đăng nhập' }
}) satisfies PageLoad
