import { api_path } from '$lib/api_call'
import type { PageLoadEvent } from './$types'

export const load = async ({ fetch, url: { searchParams } }: PageLoadEvent) => {
  const extras = { lm: 10, labels: searchParams.get('lb') }

  const path = api_path('dtopics.index', null, searchParams, extras)
  const data = await fetch(path).then((r) => r.json())

  data._meta = {
    title: 'Diễn đàn',
    left_nav: [{ text: 'Diễn đàn', icon: 'messages', href: '/forum' }],
  } satisfies App.PageMeta

  return data satisfies App.PageData
}
