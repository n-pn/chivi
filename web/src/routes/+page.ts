import { home_nav, nav_link } from '$gui/global/header_util'
import { api_get } from '$lib/api_call'
import type { PageLoad } from './$types'

interface BookList {
  recent: CV.Wninfo[]
  update: CV.Wninfo[]
  weight: CV.Wninfo[]
}

const _meta = {
  title: 'Trang chủ',
  desc: 'Truyện Tàu dịch máy, đánh giá truyện, dịch nhanh tiếng Trung...',
  left_nav: [home_nav('ps')],
  right_nav: [
    nav_link('/sp/qtran', 'Dịch nhanh', 'bolt', { show: 'tm' }),
    nav_link('/wn/crits', 'Đánh giá', 'stars', { show: 'tm' }),
  ],
}

export const load = (async ({ fetch }) => {
  const books = await api_get<BookList>('/_db/ranks/brief', fetch)
  // const ydata = await fetch('/_ys/front').then((r) => r.json())
  return { books, _meta }
}) satisfies PageLoad
