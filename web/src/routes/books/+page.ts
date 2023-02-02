import { api_path } from '$lib/api_call'
import type { LoadEvent } from '@sveltejs/kit'

interface JsonData extends CV.Paginate {
  books: CV.Nvinfo[]
}

export async function load({ url, fetch }: LoadEvent) {
  const path = api_path('wnovels.index', null, url.searchParams, { lm: 24 })
  const data: JsonData = await fetch(path).then((x) => x.json())

  // prettier-ignore
  const _meta: App.PageMeta = {
    title: 'Danh sách truyện',
    left_nav: [{ text: 'Thư viện', icon: 'books', href: '/books', 'data-kind': 'title' }],
    right_nav: [{ text: 'Thêm truyện', icon: 'file-plus', href: '/books/+book', 'data-show': 'tm' }],
  }

  return { ...data, _meta }
}
