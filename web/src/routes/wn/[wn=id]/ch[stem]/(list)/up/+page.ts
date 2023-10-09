import type { PageLoad } from './$types'
import { book_nav, seed_nav, nav_link } from '$utils/header_util'

export const load = (async ({ url, parent }) => {
  const { nvinfo, ustem } = await parent()

  const _meta: App.PageMeta = {
    left_nav: [
      book_nav(nvinfo.bslug, '', 'tl'),
      seed_nav(nvinfo.bslug, ustem.sname),
      nav_link('+bulk', 'Thêm/sửa chương', 'file-plus', { show: 'pm' }),
    ],
  }

  const start = +url.searchParams.get('start') || ustem.chmax + 1
  const _title = 'Thêm/sửa text gốc ' + nvinfo.vtitle
  return { start, ontab: 'up', _meta, _title }
}) satisfies PageLoad
