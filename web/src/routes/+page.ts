import { nav_link } from '$utils/header_util'
import { api_get } from '$lib/api_call'
import type { PageLoad } from './$types'

const _title = 'Trang chủ'
const _mdesc = 'Truyện Tàu dịch máy, đánh giá truyện, dịch nhanh tiếng Trung...'
const _image = 'https://cdn.chivi.app/imgs/avatar.png'

const _meta = { left_nav: [nav_link('/', 'Trang chủ', 'home')] }

type Wndata = { books: CV.Wninfo[] }
type Rmdata = { items: CV.Rmstem[] }
type Updata = { items: CV.Upstem[] }

export const load = (async ({ fetch }) => {
  const { books } = await api_get<Wndata>('/_db/books?lm=6', fetch)
  const { items: rstems } = await api_get<Rmdata>('/_rd/rmstems?lm=3', fetch)
  const { items: ustems } = await api_get<Updata>('/_rd/upstems?lm=3', fetch)
  return { books, rstems, ustems, _title, _mdesc, _image, _meta }
}) satisfies PageLoad
