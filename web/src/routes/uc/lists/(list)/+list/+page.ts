import { api_get } from '$lib/api_call'

import type { PageLoad } from './$types'

interface ListFormPage {
  ctime: number
  lform: CV.VilistForm
  lists: CV.Vilist[]
}

export const load = (async ({ fetch, url }) => {
  const wn = +url.searchParams.get('wn') || 0
  const id = +url.searchParams.get('id') || 0

  const path = `/_db/lists/form?id=${id}&wn=${wn}`
  const data = await api_get<ListFormPage>(path, fetch)

  return { ...data, ontab: '+list', _meta: { title: 'Tạo/sửa thư đơn' } }
}) satisfies PageLoad
