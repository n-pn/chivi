import { api_get } from '$lib/api'

interface JsonData extends CV.Paginate {
  books: CV.Nvinfo[]
}

export async function load({ url, params, fetch }) {
  const [uname, bmark = 'reading'] = params.uname.split('/')
  const page = +url.searchParams.get('pg') || 1

  const api_url = `/api/books?pg=${page}&lm=24&order=update&uname=${uname}&bmark=${bmark}`
  const api_res: JsonData = await api_get(api_url.toString(), null, fetch)

  const _meta = {
    title: 'Tủ truyện của @' + uname,
    left_nav: [
      // prettier-ignore
      { text: 'Thư viện', icon: 'books', href: '/books', 'data-show': 'md' },
      { text: 'Tủ truyện', icon: 'notebook', href: url.pathname },
    ],
  }

  return { ...api_res, uname, bmark, _meta }
}
