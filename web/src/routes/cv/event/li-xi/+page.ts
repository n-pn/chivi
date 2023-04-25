import type { PageLoad } from './$types'

export const load = (async ({ fetch, url: { searchParams } }) => {
  const pg = searchParams.get('pg') || 1
  const lm = searchParams.get('lm') || 50

  const sort = searchParams.get('sort') || '-mtime'
  const user = searchParams.get('user')

  let api_url = `/_db/li-xi/2023?pg=${pg}&lm=${lm}&sort=${sort}`
  if (user) api_url += `&user=${user}`

  const { rolls, pg_no, avail } = await fetch(api_url).then((r) => r.json())

  const _meta = {
    left_nav: [{ text: 'Lì xì năm mới', icon: 'gift', href: '/li-xi' }],
  } satisfies App.PageMeta

  return { rolls, pg_no, avail, _meta, _title: 'Chúc mừng năm mới!' }
}) satisfies PageLoad
