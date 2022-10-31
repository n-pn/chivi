throw new Error("@migration task: Migrate the load function input (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292693)");
export async function load({ stuff, fetch, url: { searchParams } }) {
  const { dboard } = stuff
  const pg = +searchParams.get('pg') || 1
  const lb = searchParams.get('lb')

  let api_url = `/api/topics?dboard=${dboard.id}&pg=${pg}&lm=10`
  if (lb) api_url += `&labels=${lb}`

  const api_res = await fetch(api_url)
  const payload = await api_res.json()

  const topbar = {
    left: [
      ['Diễn đàn', 'messages', { href: '/forum', show: 'pl' }],
      [
        dboard.bname,
        null,
        { href: `/forum/-${dboard.bslug}`, kind: 'title' },
      ],
    ],
  }

  payload.props.dboard = dboard
  payload.stuff = { topbar }
  throw new Error("@migration task: Migrate this return statement (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292693)");
  return payload
}
