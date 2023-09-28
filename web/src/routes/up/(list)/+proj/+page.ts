import { nav_link } from '$utils/header_util'
import { api_get } from '$lib/api_call'
import type { PageLoad } from './$types'

const empty_form: Partial<CV.Upstem> = {
  id: 0,
  wninfo_id: 0,

  zname: '',
  vname: '',
  uslug: '',

  vintro: '',
  labels: [],

  guard: 0,
}

export const load = (async ({ url: { searchParams }, fetch }) => {
  const id = searchParams.get('id')

  const _meta: App.PageMeta = {
    left_nav: [
      nav_link('/up', 'Dự án cá nhân', 'file', { show: 'pl' }),
      nav_link('/up/+proj', 'Thêm/Sửa', 'file-plus', { kind: 'title' }),
    ],
    right_nav: [],
  }

  let form = empty_form
  if (id) {
    const href = `/_up/projs/${id}`
    form = await api_get<CV.Upstem>(href, fetch)
  } else {
    form.wninfo_id = +searchParams.get('wn')
  }

  return { form, ontab: 'edit', _meta, _title: 'Thêm/sửa dự án cá nhân' }
}) satisfies PageLoad

// export function load() {
//
//   return { nvinfo, wnform, _meta }
// }
