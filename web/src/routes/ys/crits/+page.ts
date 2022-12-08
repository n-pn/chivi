import { get_crits } from '$lib/ys_api'

// prettier-ignore
const _meta = {
  title: 'Đánh giá',
  left_nav: [{ text: 'Đánh giá', icon: 'stars', href: '/ys/crits' }],
  right_nav: [{text: 'Thư đơn', icon: 'bookmarks', href: '/ys/lists', 'data-show': 'tm' }],
}

export async function load({ fetch, url: { searchParams } }) {
  const props = await get_crits(searchParams, { take: 10 }, fetch)
  return { ...props, _meta }
}
