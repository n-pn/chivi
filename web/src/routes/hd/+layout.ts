import { home_nav } from '$gui/global/header_util'
import type { LayoutLoad } from './$types'

export const load = (async () => {
  return {
    _meta: {
      left_nav: [home_nav('ts')],
    },
  }
}) satisfies LayoutLoad
