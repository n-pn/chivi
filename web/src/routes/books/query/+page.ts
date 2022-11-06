import { api_get } from '$lib/api'

interface JsonData extends CV.Paginate {
  books: CV.Nvinfo[]
}

const _meta: App.PageMeta = {
  title: 'Kết quả tìm kiếm cho ',
  // prettier-ignore
  left_nav: [
    { text: 'Thư viện', icon: 'books', href: '/books', 'data-show': 'md' },
    { 'text': 'Tìm kiếm', 'icon': 'search', 'href': '/books/query', 'data-kind': 'title', }
  ],
}

export async function load({ fetch, url }) {
  const pg = +url.searchParams.get('pg') || 1
  const type = url.searchParams.get('t') || 'btitle'
  const input = url.searchParams.get('q')

  const qs = input.replace(/\+|-/g, ' ').trim()
  const api_url = `/api/books?order=weight&lm=8&pg=${pg}&${type}=${qs}`
  const api_res: JsonData = await api_get(api_url.toString(), null, fetch)

  _meta.title = _meta.title + `"#${input}"`
  return { ...api_res, input, type, _meta }
}
