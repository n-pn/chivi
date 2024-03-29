import type { PageLoad } from './$types'

import { api_get } from '$lib/api_call'
import { load_crits } from '$lib/fetch_data'

const _meta = {
  title: 'Trang chủ',
  mdesc: 'Truyện Tàu dịch máy, đánh giá truyện, dịch nhanh tiếng Trung...',
  image: 'https://img.chivi.app/imgs/avatar.png',
}

const _navs: App.PageNavi[] = []
const _alts: App.PageNavi[] = [
  { href: '/mt/qtran', text: 'Dịch nhanh', icon: 'language', show: 'pl' },
]

type Wndata = { books: CV.Wninfo[] }
type Rmdata = { items: CV.Rmstem[] }
type Updata = { items: CV.Upstem[] }

export const load = (async ({ fetch }) => {
  const { books } = await api_get<Wndata>('/_db/books?lm=6', fetch)
  const { items: rstems } = await api_get<Rmdata>('/_rd/rmstems?lm=3', fetch)
  const { items: ustems } = await api_get<Updata>('/_rd/upstems?lm=3', fetch)

  const { vdata: vcrit, ydata: ycrit } = await load_crits('mixed', '?lm=2&sort=utime', fetch)

  return { vcrit, ycrit, books, rstems, ustems, _meta, _navs, _alts }
}) satisfies PageLoad
