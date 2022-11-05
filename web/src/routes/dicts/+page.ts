export type DictInfo = [string, string, number]

interface JsonData extends CV.Paginate {
  cores: DictInfo[]
  books: DictInfo[]
}

export async function load({ fetch, url }) {
  const api_url = `/api/dicts${url.search}`
  const api_res = await fetch(api_url)

  // FIXME: update api result
  const data: JsonData = (await api_res.json()).props

  const _meta: App.PageMeta = {
    title: 'Từ điển',
    left_nav: [{ text: 'Từ điển', icon: 'package', href: url.pathname }],
  }

  return { ...data, _meta }
}
