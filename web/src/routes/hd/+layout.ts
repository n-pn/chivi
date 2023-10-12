import { nav_link, home_nav } from '$utils/header_util'
import type { LayoutLoad } from './$types'

export const load = (async ({ url }) => {
  return {
    _meta: {
      left_nav: [
        home_nav(),
        nav_link(url.pathname, 'Hướng dẫn', 'article', {}),
      ],
    },
  }
}) satisfies LayoutLoad
