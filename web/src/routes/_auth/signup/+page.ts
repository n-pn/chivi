import type { PageLoad } from './$types'
export const load = (({ url }) => {
  const _meta = {
    title: 'Tài khoản mới',
    left_nav: [{ text: 'Tài khoản mới', icon: 'login', href: '.' }],
  }

  return { _meta, email: url.searchParams.get('email') || '' }
}) satisfies PageLoad
