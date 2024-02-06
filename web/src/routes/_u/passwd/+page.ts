import type { PageLoad } from './$types'

export const load = (async ({ url, parent }) => {
  const email = url.searchParams.get('email') || ''

  return {
    email,
    ontab: 'passwd',
    _navs: [{ href: '/_u/passwd', text: 'Quên mật khẩu', icon: 'key' }],
  }
}) satisfies PageLoad
