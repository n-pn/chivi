import type { LayoutLoad } from './$types'

export const load = (async ({ url }) => {
  return {
    _navs: [{ href: url.pathname, text: 'Hướng dẫn', hd_icon: 'article' }],
  }
}) satisfies LayoutLoad
