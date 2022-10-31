throw new Error("@migration task: Check if you need to migrate the load function input (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292693)");
export async function load({ fetch, url: { searchParams } }) {
  const api_url = `/_ys/lists?${searchParams.toString()}&take=10`
  const api_res = await fetch(api_url)

  const props = await api_res.json()

  const topbar = {
    left: [['Thư đơn', 'bookmarks', { href: '/lists' }]],
    right: [['Đánh giá', 'stars', { href: '/crits', show: 'tm' }]],
  }
  throw new Error("@migration task: Migrate this return statement (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292693)");
  return { props, stuff: { topbar } }
}
