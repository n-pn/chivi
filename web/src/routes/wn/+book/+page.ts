import { api_get } from '$lib/api_call'
import type { PageLoad } from './$types'

const empty_form: CV.Wnform = {
  btitle_zh: '',
  btitle_vi: '',

  author_zh: '',
  author_vi: '',

  intro_zh: '',
  intro_vi: '',

  genres: [],

  bcover: '',
  status: 0,
}

export const load = (async ({ url: { searchParams }, fetch }) => {
  let form = empty_form

  const id = searchParams.get('id')
  if (id) {
    const href = `/_db/books/${id}/edit_form`
    form = await api_get<CV.Wnform>(href, fetch)
  }

  return {
    id: 0,
    form,
    _meta: { title: 'Thêm/sửa thông tin truyện' },
    _navs: [
      { href: '/wn', text: 'Thư viện', icon: 'books', show: 'pl' },
      { href: '/wn/+book', text: 'Thêm sửa truyện', icon: 'file-plus', kind: 'title' },
    ],
  }
}) satisfies PageLoad

// export function load() {
//
//   return { nvinfo, wnform, _meta }
// }
