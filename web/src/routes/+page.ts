import { api_get } from '$lib/api_call'
import type { PageLoad } from './$types'

const _meta = {
  title: 'Trang chủ',
  mdesc: 'Truyện Tàu dịch máy, đánh giá truyện, dịch nhanh tiếng Trung...',
  image: 'https://cdn.chivi.app/imgs/avatar.png',
}

const _navs: App.PageNavi[] = []

type Wndata = { books: CV.Wninfo[] }
type Rmdata = { items: CV.Rmstem[] }
type Updata = { items: CV.Upstem[] }

export const load = (async ({ fetch }) => {
  const { books } = await api_get<Wndata>('/_db/books?lm=6', fetch)
  const { items: rstems } = await api_get<Rmdata>('/_rd/rmstems?lm=3', fetch)
  const { items: ustems } = await api_get<Updata>('/_rd/upstems?lm=3', fetch)
  return { books, rstems, ustems, _meta, _navs }
}) satisfies PageLoad
