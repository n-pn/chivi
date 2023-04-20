import { nav_link } from '$utils/header_util'
import { api_get } from '$lib/api_call'
import type { PageLoad } from './$types'

export const load: PageLoad = async ({ parent, fetch, params }) => {
  const path = `/_db/mrepls/thread/gd:${params.dt_id}`
  const rplist = await api_get<CV.Rplist>(path, fetch)

  const { cvpost } = await parent()
  const dboard = cvpost.post.dboard

  const { bslug, bname } = dboard
  const { id, title, tslug } = cvpost.post

  const _meta = {
    title: `${title} - ${bname} - Diễn đàn`,
    left_nav: [
      nav_link(`/gd/b-${bslug}`, bname, 'message', {
        kind: 'title',
      }),
      nav_link(`/gd/t-${id}-${tslug}`, title, null, { kind: 'title' }),
    ],
  }

  return { rplist, dboard, _meta }
}
