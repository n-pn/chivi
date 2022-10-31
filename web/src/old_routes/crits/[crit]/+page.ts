throw new Error("@migration task: Check if you need to migrate the load function input (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292693)");
export async function load({ fetch, params: { crit } }) {
  const api_res = await fetch(`/_ys/crits/${crit}`)
  const { entry } = await api_res.json()

  const topbar = {
    left: [
      ['Đánh giá', 'stars', { href: '/crits' }],
      [`[${crit}]`, null, { href: '.', kind: 'zseed' }],
    ],
  }

  throw new Error("@migration task: Migrate this return statement (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292693)");
  return { props: { entry }, stuff: { topbar } }
}
