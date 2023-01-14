import type { PageLoad } from './$types'
export const load = (({ url }) => {
  const _meta = {
    title: 'Đăng nhập',
    left_nav: [{ text: 'Đăng nhập', icon: 'login', href: '.' }],
  }

  return { _meta, email: url.searchParams.get('email') || '' }
}) satisfies PageLoad
