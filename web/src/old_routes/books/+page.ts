import { wrap_get } from '$lib/api_call'

export async function load({ url, fetch }) {
  const api_url = new URL(url)
  api_url.pathname = '/api/books'
  api_url.searchParams.set('lm', '24')

  const topbar = {
    right: [
      ['Thêm truyện', 'file-plus', { href: '/books/+book', show: 'tm' }],
    ],
    search: '',
  }
  throw new Error("@migration task: Migrate this return statement (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292693)");
  return await wrap_get(fetch, api_url.toString(), null, null, { topbar })
}

const order_names = {
  bumped: 'Vừa xem',
  update: 'Đổi mới',
  rating: 'Đánh giá',
  weight: 'Tổng hợp',
}
