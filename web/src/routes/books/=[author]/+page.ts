import { api_path } from '$lib/api_call'

interface JsonData extends CV.Paginate {
  books: CV.Nvinfo[]
}

export async function load({ fetch, url, params: { author } }) {
  const extras = { lm: 8, order: 'weight' }

  const path = api_path('nvinfos.index', null, url.searchParams, extras)
  const data: JsonData = await fetch(path).then((x: Response) => x.json())

  const _meta: App.PageMeta = {
    title: 'Kết quả tìm kiếm cho ',
    // prettier-ignore
    left_nav: [
      { text: 'Thư viện', icon: 'books', href: '/books', 'data-show': 'md' },
      { 'text': author, 'icon': 'edit', 'href': `/books/=${author}`, 'data-kind': 'title', }
    ],
  }

  return { ...data, author, _meta }
}
