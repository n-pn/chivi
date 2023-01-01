import type { PageLoad } from './$types'
export const load = (() => {
  const _meta = {
    title: 'Đăng nhập',
    left_nav: [{ text: 'Đăng nhập', icon: 'login', href: '.' }],
  }

  return { _meta }
}) satisfies PageLoad
