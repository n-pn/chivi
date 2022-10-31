export async function load({ fetch, url }) {
  const api_res = await fetch(`/api/tlspecs${url.search}`)
  const payload = await api_res.json()

  const topbar = {
    left: [['Lỗi máy dịch', 'flag', { href: url.pathname }]],
    config: true,
  }

  payload.stuff = { topbar }
  throw new Error("@migration task: Migrate this return statement (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292693)");
  return payload
}
