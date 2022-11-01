// prettier-ignore
const _meta : App.PageMeta = {
  title: 'Diễn đàn',
  left_nav: [{text: 'Diễn đàn', icon: 'messages',  href: '/forum' }],
}

export async function load({ fetch, url }) {
  const pg = url.searchParams.get('pg') || 1
  const lb = url.searchParams.get('lb')

  let api_url = `/api/topics?pg=${pg}&lm=10`
  if (lb) api_url += `&labels=${lb}`

  const api_res = await fetch(api_url)
  const { props } = await api_res.json()

  return { ...props, _meta }
}
