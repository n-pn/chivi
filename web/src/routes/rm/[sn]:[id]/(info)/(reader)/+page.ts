import { api_get } from '$lib/api_call'
import { nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

export const load = (async ({ fetch, url, params, parent }) => {
  const { rstem, sroot } = await parent()

  const pg_no = +url.searchParams.get('pg') || 1
  const api_url = `/_rd/rmchaps/${+params.id}?pg=${pg_no}`

  const chaps = await api_get<CV.Wnchap[]>(api_url, fetch)
  const _title = `Dự án cá nhân của ${rstem.sname}: ${rstem.vname}`

  const _meta: App.PageMeta = {
    left_nav: [
      nav_link('/up', 'Dự án cá nhân', 'file', { show: 'ts' }),
      nav_link(sroot, rstem.vname, 'list', { show: 'pl', kind: 'title' }),
    ],
  }

  return { chaps, pg_no, sroot, _title, _meta, ontab: 'ch' }
}) satisfies PageLoad
