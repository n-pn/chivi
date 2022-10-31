export async function load({ fetch, url }) {
  const api_url = `/api/dicts${url.search}`
  const api_res = await fetch(api_url)
  const payload = await api_res.json()

  const topbar = { left: [['Từ điển', 'package', { href: '/dicts' }]] }
  payload.stuff = { topbar }

  throw new Error("@migration task: Migrate this return statement (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292693)");
  return payload
}
