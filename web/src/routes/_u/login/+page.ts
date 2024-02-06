import type { PageLoad } from './$types'

export const load = (async ({ url, parent }) => {
  const email = url.searchParams.get('email') || ''

  return {
    email,
    ontab: 'login',
    _navs: [{ href: '/_u/login', text: 'Đăng nhập', icon: 'login' }],
  }
}) satisfies PageLoad
