import type { LayoutLoad } from './$types'

export const load = (async ({ url }) => {
  return {
    _navs: [{ href: url.pathname, text: 'Hướng dẫn', icon: 'article' }],
  }
}) satisfies LayoutLoad
