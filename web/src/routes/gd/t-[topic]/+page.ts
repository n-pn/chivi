import { home_nav, nav_link } from '$utils/header_util'
import { api_get } from '$lib/api_call'
import type { PageLoad } from './$types'

export const load: PageLoad = async ({ fetch, params }) => {
  const dt_id = parseInt(params.topic, 10)

  const rppath = `/_db/mrepls/thread/gd:${dt_id}`
  const rplist = await api_get<CV.Rplist>(rppath, fetch)

  const dtpath = `/_db/topics/${dt_id}`
  const cvpost = await api_get<CV.DtopicFull>(dtpath, fetch)

  const { dboard, title } = cvpost.post

  const _meta = {
    title: `${title} -  Diễn đàn`,
    left_nav: [
      home_nav('tm'),
      nav_link('/gd', 'Diễn đàn', 'messages'),
      nav_link(`/gd/t-${params.topic}`, title, null, { kind: 'title' }),
    ],
  }

  return { cvpost, rplist, dboard, _meta }
}
