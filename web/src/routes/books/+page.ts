import { api_get } from '$lib/api_call'

interface JsonData extends CV.Paginate {
  books: CV.Nvinfo[]
}

export async function load({ url, fetch }) {
  const api_url = new URL(url)
  api_url.pathname = '/api/books'
  api_url.searchParams.set('lm', '24')

  const api_res: JsonData = await api_get(api_url.toString(), null, fetch)

  // prettier-ignore
  const _meta: App.PageMeta = {
    title: 'Danh sách truyện',
    left_nav: [{ text: 'Thư viện', icon: 'books', href: '/books', 'data-kind': 'title' }],
    right_nav: [{ text: 'Thêm truyện', icon: 'file-plus', href: '/books/+book', 'data-show': 'tm' }],
  }

  return { ...api_res, _meta }
}
