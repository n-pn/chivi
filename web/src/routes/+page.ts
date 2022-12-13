import type { LoadEvent } from '@sveltejs/kit'

export const load = async ({ fetch }: LoadEvent) => {
  const books = await fetch('/api/ranks/brief').then((r) => r.json())
  const { ycrits, ylists } = await fetch('/_ys').then((r) => r.json())

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
