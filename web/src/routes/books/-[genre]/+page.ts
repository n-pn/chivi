import { api_path } from '$lib/api_call'

interface JsonData extends CV.Paginate {
  books: CV.Nvinfo[]
}

export async function load({ url, fetch, params: { genre } }) {
  const extras = { lm: 24, order: 'weight' }
  const path = api_path('nvinfos.index', null, url.searchParams, extras)
  const data: JsonData = await fetch(path).then((x: Response) => x.json())

  const _meta = {
    title: 'Lọc truyện theo thể loại',
    left_nav: [
      // prettier-ignore
      { text: 'Thư viện', icon: 'books', href: '/books', 'data-show': 'md' },
      { text: 'Thể loại', icon: 'folder', href: url.pathname },
    ],
  }

  return { ...data, genres: genre.split('+'), _meta }
}
