import { load_lists } from '$lib/fetch_data'
import { home_nav, book_nav, nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

export const load = (async ({ url, fetch, parent }) => {
  const { nvinfo, _navs } = await parent()

  const data = await load_lists(url, fetch, { book: nvinfo.id })

  return {
    ...data,
    ontab: 'lists',
    _meta: {
      title: `Thư đơn có: ${nvinfo.vtitle}`,
      mdesc: nvinfo.bintro.substring(0, 150),
    },

    _navs: [
      ..._navs,
      {
        href: `/wn/${nvinfo.id}/lists`,
        text: 'Thư đơn',
        hd_icon: 'bookmarks',
      },
    ],
  }
}) satisfies PageLoad
