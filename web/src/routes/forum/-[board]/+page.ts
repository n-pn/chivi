export async function load({ parent, fetch, url: { searchParams } }) {
  const { dboard } = await parent()

  const pg = +searchParams.get('pg') || 1
  const lb = searchParams.get('lb')

  let api_url = `/api/topics?dboard=${dboard.id}&pg=${pg}&lm=10`
  if (lb) api_url += `&labels=${lb}`

  const api_res = await fetch(api_url)
  const { props } = await api_res.json()

  const _meta: App.PageMeta = {
    title: 'Diễn đàn: ' + dboard.bname,
    left_nav: [
      { text: 'Diễn đàn', icon: 'messages', href: '/forum' },
      // prettier-ignore
      { 'text': dboard.bname, 'href': `/forum/-${dboard.bslug}`, 'data-kind': 'title', },
    ],
  }

  return { ...props, dboard, _meta }
}
