import { nav_link } from '$utils/header_util'

import { api_get, merge_query } from '$lib/api_call'

import type { PageLoadEvent } from './$types'

export async function load({ parent, fetch, url }: PageLoadEvent) {
  const { dboard } = await parent()
  const search = merge_query(url.searchParams, { dboard: dboard.id, lm: 10 })
  const dtlist = await api_get<CV.Dtlist>(`/_db/topics?${search}`, fetch)

  const _meta = {
    left_nav: [
      nav_link('/gd', 'Diễn đàn', 'messages'),
      nav_link(`/gd/b-${dboard.bslug}`, dboard.bname, 'messages', {
        kind: 'title',
      }),
    ],
  } satisfies App.PageMeta

  return { dtlist, _meta, _title: 'Diễn đàn: ' + dboard.bname }
}
