import type { PageLoad } from '../$types'

export const load = (async ({ fetch, url: { searchParams } }) => {
  const path = '/_db/li-xi/2023'
  const { rolls, pg_no, avail } = await fetch(path).then((r) => r.json())

  const _meta = {
    title: 'Chúc mừng năm mới!',
    left_nav: [{ text: 'Lì xì năm mới', icon: 'gift', href: '/li-xi' }],
  } satisfies App.PageMeta

  return { rolls, pg_no, avail, _meta }
}) satisfies PageLoad
