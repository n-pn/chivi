import type { PageLoad } from './$types'
export const load = (() => {
  const _meta = {
    title: 'Quên mật khẩu',
    left_nav: [{ text: 'Quên mật khẩu', icon: 'login', href: '.' }],
  }

  return { _meta }
}) satisfies PageLoad
