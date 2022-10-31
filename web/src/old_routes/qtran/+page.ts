export async function load({ url }) {
  const dname = url.searchParams.get('dname') || 'combine'
  const input = url.searchParams.get('input')

  const topbar = {
    left: [['Dịch nhanh', 'bolt', { href: '/qtran' }]],
  }
  throw new Error("@migration task: Migrate this return statement (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292693)");
  return { props: { dname, input: input }, stuff: { topbar } }
}
