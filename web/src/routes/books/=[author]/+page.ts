import { api_get } from '$lib/api_call'

interface JsonData extends CV.Paginate {
  books: CV.Nvinfo[]
}

export async function load({ fetch, url, params: { author } }) {
  const page = +url.searchParams.get('pg') || 1
  const api_url = `/api/books?order=weight&lm=8&pg=${page}&author=${author}`
  const api_res: JsonData = await api_get(api_url.toString(), null, fetch)

  const _meta: App.PageMeta = {
    title: 'Kết quả tìm kiếm cho ',
    // prettier-ignore
    left_nav: [
      { text: 'Thư viện', icon: 'books', href: '/books', 'data-show': 'md' },
      { 'text': author, 'icon': 'edit', 'href': `/books/=${author}`, 'data-kind': 'title', }
    ],
  }

  return { ...api_res, author, _meta }
}
