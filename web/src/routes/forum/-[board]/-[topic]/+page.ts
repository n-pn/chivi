import { api_path } from '$lib/api_call'
import type { PageLoad } from './$types'

export const load: PageLoad = async ({ parent, fetch, url }) => {
  const { dboard, cvpost } = await parent()

  const extras = { post_id: cvpost.id }
  const path = api_path(`/_db/tposts`, null, url.searchParams, extras)

  const tplist = await fetch(path).then((r) => r.json())

  const _meta = {
    title: 'Diễn đàn: ' + dboard.bname,
    left_nav: [
      // prettier-ignore
      { 'text': dboard.bname, icon:'message', 'href': `/forum/-${dboard.bslug}`, 'data-kind': 'title', },
      { 'text': cvpost.title, 'href': '.', 'data-kind': 'title' },
    ],
  }

  return { tplist, _meta }
}
