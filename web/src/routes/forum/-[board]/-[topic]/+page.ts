export async function load({ parent, fetch, url }) {
  const { dboard, cvpost } = await parent()

  const pg = url.searchParams.get('pg') || 1

  const api_url = `/api/tposts?cvpost=${cvpost.id}&pg=${pg}&lm=20`
  const api_res = await fetch(api_url)
  const { props } = await api_res.json()

  const _meta: App.PageMeta = {
    title: 'Diễn đàn: ' + dboard.bname,
    left_nav: [
      // prettier-ignore
      { 'text': dboard.bname, icon:'message', 'href': `/forum/-${dboard.bslug}`, 'data-kind': 'title', },
      { 'text': cvpost.title, 'href': '.', 'data-kind': 'title' },
    ],
  }

  return { ...props, _meta }
}
