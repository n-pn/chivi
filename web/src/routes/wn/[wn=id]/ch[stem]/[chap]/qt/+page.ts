import {
  call_btran_file,
  call_qtran_file,
  call_hviet_file,
} from '$utils/tran_util'

import { gen_hviet_text } from '$lib/mt_data_2'

import type { PageLoad } from './$types'

export const load = (async ({ fetch, parent, depends }) => {
  const { xargs } = await parent()
  xargs.type = 'qt'
  depends(`wn:qt:${xargs.rmode}`)

  const vtran = await load_data(xargs, fetch)
  return { vtran }
}) satisfies PageLoad

const rinit = { cache: 'force-cache' } as RequestInit

async function load_data({ spath, rmode }: CV.Chopts, fetch: CV.Fetch) {
  if (!spath) return { lines: [], mtime: 0, tspan: 0 }

  const finit = { fpath: spath, ftype: 'nc', force: true }

  switch (rmode) {
    case 'be_zv':
      return await call_btran_file(finit, rinit, fetch)

    case 'qt_v1':
      return await call_qtran_file(finit, rinit, fetch)

    // case 'hviet':
    default:
      const data = await call_hviet_file(finit, rinit, fetch)
      const { hviet, tspan, mtime, error } = data
      const lines = hviet.map((hvarr) => gen_hviet_text(hvarr, true))
      return { lines, hviet, tspan, mtime, error }
  }
}
