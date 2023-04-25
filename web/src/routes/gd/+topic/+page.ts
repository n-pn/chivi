import { api_get } from '$lib/api_call'
import { home_nav, nav_link } from '$utils/header_util'

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

  const curr_path = `/gd/+topic${url.search}`

  const _meta = {
    left_nav: [
      home_nav('tm'),
      nav_link('/gd', 'Diễn đàn', 'messages', { show: 'ts' }),
      nav_link(curr_path, 'Tạo/sửa chủ đề', 'edit', { show: 'ts' }),
    ],
    right_nav: [],
  }
  return { dboard, dtform, _meta, _title: 'Tạo/sửa chủ đề' }
}) satisfies PageLoad
