import { api_get } from '$lib/api_call'
import { nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

export const load = (async ({ fetch, url, params, parent }) => {
  const pg_no = +url.searchParams.get('pg') || 1
  const rdurl = `/_rd/chaps/up/${params.sn}/${params.id}`

  const chaps = await api_get<CV.Wnchap[]>(`${rdurl}?pg=${pg_no}`, fetch)
  const lasts = await api_get<CV.Wnchap[]>(`${rdurl}?lm=4&_last=true`, fetch)

  const { ustem, sroot } = await parent()
  const _title = `Sưu tầm của ${ustem.sname}: ${ustem.vname}`

  const _meta: App.PageMeta = {
    left_nav: [
      nav_link('/up', 'Sưu tầm cá nhân', 'file', { show: 'ts' }),
      nav_link(sroot, ustem.vname, 'list', { show: 'pl', kind: 'title' }),
    ],
  }

  return { chaps, lasts, pg_no, sroot, _title, _meta, intab: 'rd', ontab: 'ch' }
}) satisfies PageLoad
