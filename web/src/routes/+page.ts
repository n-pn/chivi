import { home_nav } from '$utils/header_util'
import { api_get } from '$lib/api_call'
import type { PageLoad } from './$types'

interface BookList {
  recent: CV.Wninfo[]
  update: CV.Wninfo[]
  weight: CV.Wninfo[]
}

const _title = 'Trang chủ'
const _mdesc = 'Truyện Tàu dịch máy, đánh giá truyện, dịch nhanh tiếng Trung...'
const _image = '/imgs/avatar.png'

const _meta = { left_nav: [home_nav('ps')] }

export const load = (async ({ fetch }) => {
  const books = await api_get<BookList>('/_db/ranks/brief', fetch)
  // const ydata = await fetch('/_ys/front').then((r) => r.json())
  return { books, _title, _mdesc, _image, _meta }
}) satisfies PageLoad
