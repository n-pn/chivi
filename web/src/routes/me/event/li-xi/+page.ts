import { error, type NumericRange } from '@sveltejs/kit'
import type { PageLoad } from './$types'

export const load = (async ({ fetch, url: { searchParams } }) => {
  const pg = searchParams.get('pg') || 1
  const lm = searchParams.get('lm') || 50

  const sort = searchParams.get('sort') || '-mtime'
  const user = searchParams.get('user')

  let api_url = `/_db/li-xi/tet-2024?pg=${pg}&lm=${lm}&sort=${sort}`
  if (user) api_url += `&user=${user}`

  const res = await fetch(api_url)
  if (!res.ok) throw error(res.status as NumericRange<400, 599>, await res.text())
  const { rolls, pg_no, avail } = await res.json()

  return {
    rolls,
    pg_no,
    avail,
    _navs: [{ text: 'Lì xì năm mới', icon: 'gift', href: '/me/event/li-xi' }],
    _meta: { title: 'Lì xì năm mới' },
  }
}) satisfies PageLoad
