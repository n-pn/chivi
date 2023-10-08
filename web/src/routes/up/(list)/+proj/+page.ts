import { nav_link } from '$utils/header_util'
import { api_get } from '$lib/api_call'
import type { PageLoad } from './$types'

const empty_form: Partial<CV.Upstem> = {
  id: 0,
  wn_id: 0,

  zname: '',
  vname: '',
  uslug: '',

  vintro: '',
  labels: [],

  guard: 0,
}

const _meta: App.PageMeta = {
  left_nav: [
    nav_link('/up', 'Sưu tầm cá nhân', 'album', { show: 'pl' }),
    nav_link('/up/+proj', 'Thêm mới', 'file-plus', { kind: 'title' }),
  ],
  right_nav: [],
}

export const load = (async ({ url: { searchParams }, fetch }) => {
  let form = empty_form
  form.wn_id = +searchParams.get('wn')

  return { form, ontab: '+new', _meta, _title: 'Tạo sưu tầm cá nhân' }
}) satisfies PageLoad

// export function load() {
//
//   return { nvinfo, wnform, _meta }
// }
