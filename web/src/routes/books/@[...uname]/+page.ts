import { api_path } from '$lib/api_call'
import type { PageLoadEvent } from './$types'

interface JsonData extends CV.Paginate {
  books: CV.Nvinfo[]
}

export async function load({ url, params, fetch }: PageLoadEvent) {
  const [uname, bmark = 'reading'] = params.uname.split('/')
  const extras = { lm: 24, order: 'update', uname, bmark }

  const path = api_path('wnovels.index', null, url.searchParams, extras)
  const data: JsonData = await fetch(path).then((x) => x.json())

  const _meta = {
    title: `Tủ truyện của @${uname}`,
    left_nav: [
      // prettier-ignore
      { text: 'Thư viện', icon: 'books', href: '/books', 'data-show': 'md' },
      { text: 'Tủ truyện', icon: 'notebook', href: url.pathname },
    ],
  }

  return { ...data, uname, bmark, _meta }
}
