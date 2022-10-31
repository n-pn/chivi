export async function load({ fetch, url }) {
  const pg = url.searchParams.get('pg') || 1
  const lb = url.searchParams.get('lb')

  let api_url = `/api/topics?pg=${pg}&lm=10`
  if (lb) api_url += `&labels=${lb}`

  const api_res = await fetch(api_url)
  const payload = await api_res.json()

  const topbar = {
    left: [['Diễn đàn', 'messages', { href: '/forum' }]],
  }
  payload.stuff = { topbar }
  throw new Error("@migration task: Migrate this return statement (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292693)");
  return payload
}
