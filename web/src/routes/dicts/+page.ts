import { api_path } from '$lib/api_call'

export type DictInfo = [string, string, number]

interface JsonData extends CV.Paginate {
  cores: DictInfo[]
  books: DictInfo[]
}

export async function load({ fetch, url }) {
  const path = api_path('v1dict.index', 0, url.searchParams)

  // FIXME: update api result
  const data: JsonData = await fetch(path).then((x: Response) => x.json())

  const _meta: App.PageMeta = {
    title: 'Từ điển',
    left_nav: [{ text: 'Từ điển', icon: 'package', href: url.pathname }],
  }

  return { ...data, _meta }
}
