import { nav_link } from '$utils/header_util'
import { api_get } from '$lib/api_call'
import type { PageLoad } from './$types'

const empty_form: CV.WnForm = {
  ztitle: '',
  vtitle: '',

  zauthor: '',
  vauthor: '',

  zintro: '',
  vintro: '',

  genres: [],

  bcover: '',
  status: 0,
}

export const load = (async ({ url: { searchParams }, fetch }) => {
  const id = searchParams.get('id')

  const _meta: App.PageMeta = {
    title: 'Thêm/sửa thông tin truyện',
    left_nav: [
      nav_link('/wn', 'Thư viện', 'books', { show: 'md' }),
      nav_link('/wn/+book', 'Thêm sửa truyện', 'file-plus', { kind: 'title' }),
    ],
    right_nav: [],
  }

  let form = empty_form

  if (id) {
    const href = `/_db/books/${id}/edit_form`
    form = await api_get<CV.WnForm>(href, fetch)

    const right_nav = nav_link(`/wn/${id}-`, 'Về bộ truyện', 'arrow-back-up', {
      show: 'tm',
    })
    _meta.right_nav.push(right_nav)
  }

  return { id: 0, form, _meta }
}) satisfies PageLoad

// export function load() {
//
//   return { nvinfo, wnform, _meta }
// }
