import type { LoadEvent } from '@sveltejs/kit'

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

export const load = async ({ fetch }: LoadEvent) => {
  // const ydata = await fetch('/_ys/front').then((r) => r.json())
  const books = await fetch('/_db/ranks/brief').then((r) => r.json())
  return { books, _meta }
}
