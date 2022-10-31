throw new Error("@migration task: Migrate the load function input (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292693)");
export async function load({ stuff, fetch, url }) {
  const { dboard, cvpost } = stuff

  const pg = url.searchParams.get('pg') || 1

  const api_url = `/api/tposts?cvpost=${cvpost.id}&pg=${pg}&lm=20`
  const api_res = await fetch(api_url)
  const payload = await api_res.json()

  payload.props.dboard = dboard
  payload.props.cvpost = cvpost

  const board_url = `/forum/-${dboard.bslug}`

  const topbar = {
    left: [
      ['Diễn đàn', 'messages', { href: '/forum', show: 'tl' }],
      [
        dboard.bname,
        'message',
        { href: board_url, show: 'tm', kind: 'title' },
      ],
      [cvpost.title, null, { href: '.', kind: 'title' }],
    ],
  }

  payload.stuff = { topbar }
  throw new Error("@migration task: Migrate this return statement (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292693)");
  return payload
}
