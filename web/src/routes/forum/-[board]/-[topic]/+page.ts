import { api_path } from '$lib/api_call'
import type { PageLoad } from './$types'

export const load: PageLoad = async ({ parent, fetch, url }) => {
  const { dboard, cvpost } = await parent()

  const extras = { cvpost: cvpost.id, lm: 20 }
  const path = api_path('dtposts.index', null, url.searchParams, extras)
  const data = await fetch(path).then((r) => r.json())

  data._meta = {
    title: 'Diễn đàn: ' + dboard.bname,
    left_nav: [
      // prettier-ignore
      { 'text': dboard.bname, icon:'message', 'href': `/forum/-${dboard.bslug}`, 'data-kind': 'title', },
      { 'text': cvpost.title, 'href': '.', 'data-kind': 'title' },
    ],
  }

  return data
}
