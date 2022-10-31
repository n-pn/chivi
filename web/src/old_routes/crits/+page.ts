import { get_crits } from '$lib/ys_api'

throw new Error("@migration task: Check if you need to migrate the load function input (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292693)");
export async function load({ fetch, url: { searchParams } }) {
  const props = await get_crits(searchParams, { take: 10 }, fetch)

  const topbar = {
    left: [['Đánh giá', 'stars', { href: '/crits' }]],
    right: [['Thư đơn', 'bookmarks', { href: '/lists', show: 'tm' }]],
  }

  throw new Error("@migration task: Migrate this return statement (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292693)");
  return { props, stuff: { topbar } }
}
