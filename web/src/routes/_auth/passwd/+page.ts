import type { PageLoad } from './$types'
export const load = (({ url }) => {
  const _meta = {
    title: 'Quên mật khẩu',
    left_nav: [{ text: 'Quên mật khẩu', icon: 'login', href: '.' }],
  }

  return { _meta, email: url.searchParams.get('email') || '' }
}) satisfies PageLoad
