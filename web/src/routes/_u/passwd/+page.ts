import { nav_link, home_nav } from '$utils/header_util'
import type { PageLoad } from './$types'

const _meta: App.PageMeta = {
  left_nav: [home_nav(), nav_link('paswrd', 'Quên mật khẩu', 'key')],
}

export const load = (({ url }) => {
  const email = url.searchParams.get('email') || ''
  return { email, _meta, _title: 'Quên mật khẩu', ontab: 'passwd' }
}) satisfies PageLoad
