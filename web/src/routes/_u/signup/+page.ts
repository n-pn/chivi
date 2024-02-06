import type { PageLoad } from './$types'

export const load = (async ({ url }) => {
  const email = url.searchParams.get('email') || ''

  return {
    email,
    ontab: 'signup',
    _navs: [{ href: '/_u/signup', text: 'Tạo tài khoản', icon: 'user-plus' }],
  }
}) satisfies PageLoad
