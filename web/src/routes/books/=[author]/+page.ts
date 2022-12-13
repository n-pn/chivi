import { api_path } from '$lib/api_call'
import type { PageLoadEvent } from './$types'

interface JsonData extends CV.Paginate {
  books: CV.Nvinfo[]
}

export async function load({ fetch, url, params: { author } }: PageLoadEvent) {
  const extras = { lm: 8, order: 'weight' }

  const path = api_path('nvinfos.index', null, url.searchParams, extras)
  const data: JsonData = await fetch(path).then((x) => x.json())

  const _meta = {
    title: 'Kết quả tìm kiếm cho ',
    // prettier-ignore
    left_nav: [
      { text: 'Thư viện', icon: 'books', href: '/books', 'data-show': 'md' },
      { 'text': author, 'icon': 'edit', 'href': `/books/=${author}`, 'data-kind': 'title', }
    ],
  } satisfies App.PageMeta

  return { ...data, author, _meta }
}
