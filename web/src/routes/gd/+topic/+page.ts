import { api_get } from '$lib/api_call'
import type { PageLoad } from './$types'

interface TopicFormPage {
  dboard: CV.Dboard
  dtform: CV.DtopicForm
}

export const load = (async ({ fetch, url }) => {
  const tb = +url.searchParams.get('tb') || 0
  const id = +url.searchParams.get('id') || 0

  const path = `/_db/topics/form?tb=${tb}&id=${id}`
  const { dboard, dtform } = await api_get<TopicFormPage>(path, fetch)

  const href = `/gd/+topic${url.search}`

  return {
    dboard,
    dtform,
    _meta: { title: 'Tạo/sửa chủ đề' },
    _navs: [
      { href: '/gd', text: 'Diễn đàn', icon: 'messages', show: 'ts' },
      { href: href, text: 'Tạo/sửa chủ đề', icon: 'edit' },
    ],
  }
}) satisfies PageLoad
