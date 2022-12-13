import { api_path } from '$lib/api_call'
import type { PageLoadEvent } from './$types'

export async function load({ parent, fetch, url }: PageLoadEvent) {
  const { dboard } = await parent()

  const extras = { dboard: dboard.id, lm: 10 }
  const path = api_path('dtopics.index', null, url.searchParams, extras)
  const data = await fetch(path).then((r) => r.json())

  data._meta = {
    title: 'Diễn đàn: ' + dboard.bname,
    left_nav: [
      { text: 'Diễn đàn', icon: 'messages', href: '/forum' },
      // prettier-ignore
      { 'text': dboard.bname, 'href': `/forum/-${dboard.bslug}`, 'data-kind': 'title', },
    ],
  } satisfies App.PageMeta

  return data
}
