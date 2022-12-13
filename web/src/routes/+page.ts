import { api_get } from '$lib/api_call'

export async function load({ fetch }) {
  const books = await api_get('/api/ranks/brief', null, fetch)
  const { ycrits, ylists } = await api_get('/_ys', null, fetch)

  const _meta: App.PageMeta = {
    title: 'Trang chủ',
    desc: 'Truyện Tàu dịch máy, đánh giá truyện, dịch nhanh tiếng Trung...',
    right_nav: [
      {
        'text': 'Dịch nhanh',
        'icon': 'bolt',
        'href': '/qtran',
        'data-show': 'tm',
      },
      {
        'text': 'Đánh giá',
        'icon': 'stars',
        'href': '/crits',
        'data-show': 'tm',
      },
    ],
  }

  return { books, ycrits, ylists, _meta }
}
