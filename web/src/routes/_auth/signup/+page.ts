import type { PageLoad } from './$types'
export const load = (() => {
  const _meta = {
    title: 'Tài khoản mới',
    left_nav: [{ text: 'Tài khoản mới', icon: 'login', href: '.' }],
  }

  return { _meta }
}) satisfies PageLoad
