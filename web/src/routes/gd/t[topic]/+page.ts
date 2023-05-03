import { home_nav, nav_link } from '$utils/header_util'
import { api_get } from '$lib/api_call'
import type { PageLoad } from './$types'

export const load: PageLoad = async ({ fetch, params }) => {
  const dt_id = parseInt(params.topic, 10)

  const dtpath = `/_db/topics/${dt_id}`
  const dtopic = await api_get<CV.Dtopic>(dtpath, fetch)

  const rppath = `/_db/droots/show/dt:${dt_id}`
  const { rplist } = await api_get<{ rplist: CV.Rplist }>(rppath, fetch)

  const _meta = {
    left_nav: [
      home_nav('tm'),
      nav_link('/gd', 'Diễn đàn', 'messages'),
      nav_link(`/gd/t${params.topic}`, dtopic.title, null, { kind: 'title' }),
    ],
  }

  return { dtopic, rplist, _meta, _title: `${dtopic.title} -  Diễn đàn` }
}
