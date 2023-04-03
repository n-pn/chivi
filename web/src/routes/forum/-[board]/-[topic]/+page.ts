import { api_get, merge_query } from '$lib/api_call'
import type { PageLoad } from './$types'

export const load: PageLoad = async ({ parent, fetch, url }) => {
  const { dboard, cvpost } = await parent()

  const search = merge_query(url.searchParams, { post: cvpost.post.id })
  const rplist = await api_get<CV.Rplist>(`/_db/tposts?${search}`, fetch)

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
