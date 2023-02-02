import { api_path } from '$lib/api_call'
import type { PageLoadEvent } from './$types'

interface JsonData extends CV.Paginate {
  books: CV.Nvinfo[]
}

export async function load({ fetch, url: { searchParams } }: PageLoadEvent) {
  const type = searchParams.get('t') || 'btitle'
  const input = searchParams.get('q').replace('+', ' ')
  const extras = { order: 'weight', lm: 8, [type]: input }

  const path = api_path('wnovels.index', null, searchParams, extras)
  const data: JsonData = await fetch(path).then((x) => x.json())

  const _meta: App.PageMeta = {
    title: `Kết quả tìm kiếm cho "${input}"`,
    // prettier-ignore
    left_nav: [
      { text: 'Thư viện', icon: 'books', href: '/books', 'data-show': 'md' },
      { 'text': 'Tìm kiếm', 'icon': 'search', 'href': '/books/query', 'data-kind': 'title' }
    ],
  }

  return { ...data, input, type, _meta }
}
