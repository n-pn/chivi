import { api_path } from '$lib/api_call'
import type { PageLoadEvent } from './$types'

export type DictInfo = [string, string, number]

interface JsonData extends CV.Paginate {
  cores: DictInfo[]
  books: DictInfo[]
}

export async function load({ fetch, url }: PageLoadEvent) {
  const path = api_path('v1dict.index', 0, url.searchParams)

  // FIXME: update api result
  const data: JsonData = await fetch(path).then((x) => x.json())

  const _meta: App.PageMeta = {
    title: 'Từ điển',
    left_nav: [{ text: 'Từ điển', icon: 'package', href: url.pathname }],
  }

  return { ...data, _meta }
}
