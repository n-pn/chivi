import { load_lists } from '$lib/fetch_data'
import { home_nav, book_nav, nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

export const load = (async ({ url, fetch, parent, params }) => {
  const book = params.wn_id
  const data = await load_lists(url, fetch, { book })

  const { nvinfo } = await parent()
  const _meta = build_meta(nvinfo)

  return { ...data, _meta }
}) satisfies PageLoad

const build_meta = (book: CV.Wninfo) => {
  return {
    title: `${book.vtitle}`,
    desc: book.bintro.substring(0, 300),
    left_nav: [
      home_nav('', ''),
      book_nav(book.bslug, book.vtitle, 'tm'),
      nav_link('lists', 'Thư đơn', 'bookmarks'),
    ],
    right_nav: [
      nav_link('/wn/lists/+list', 'Tạo mới', 'circle-plus', { show: 'tl' }),
    ],
  }
}
