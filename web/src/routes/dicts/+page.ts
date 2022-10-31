export type DictInfo = [string, string, number]

interface JsonData extends CV.Paginate {
  cores: DictInfo[]
  books: DictInfo[]
}

export async function load({ fetch, url }) {
  const api_url = `/api/dicts${url.search}`
  const api_res = await fetch(api_url)
  // FIXME: update api result
  const data: JsonData = await api_res.json().props
  const _head_left: App.TopbarItem[] = [
    { text: 'Từ điển', icon: 'package', href: '/dicts' },
  ]

  return { ...data, _head_left }
}
