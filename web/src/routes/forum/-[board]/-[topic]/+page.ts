import { api_get } from '$lib/api_call'
import type { PageLoad } from './$types'

export const load: PageLoad = async ({ parent, fetch, params }) => {
  const topic_id = params.topic.split('-').pop()
  const api_path = `/_db/mrepls/thread/${topic_id}/0`
  const rplist = await api_get<CV.Rplist>(api_path, fetch)

  const { dboard, cvpost } = await parent()

  const _meta = {
    title: 'Diễn đàn: ' + dboard.bname,
    left_nav: [
      // prettier-ignore
      { 'text': dboard.bname, icon:'message', 'href': `/forum/-${dboard.bslug}`, 'data-kind': 'title', },
      { 'text': cvpost.post.title, 'href': '.', 'data-kind': 'title' },
    ],
  }

  return { rplist, _meta }
}
