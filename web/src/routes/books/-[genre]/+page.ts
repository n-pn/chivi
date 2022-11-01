import { api_get } from '$lib/api'

interface JsonData extends CV.Paginate {
  books: CV.Nvinfo[]
}

export async function load({ url, fetch, params: { genre } }) {
  const api_url = new URL(url)
  api_url.pathname = '/api/books'
  api_url.searchParams.set('lm', '24')
  api_url.searchParams.set('genre', genre)

  const api_res: JsonData = await api_get(api_url.toString(), null, fetch)

  const _meta = {
    title: 'Lọc truyện theo thể loại',
    left_nav: [
      // prettier-ignore
      { text: 'Thư viện', icon: 'books', href: '/books', 'data-show': 'md' },
      { text: 'Thể loại', icon: 'folder', href: url.pathname },
    ],
  }

  return { ...api_res, genres: genre.split('+'), _meta }
}
