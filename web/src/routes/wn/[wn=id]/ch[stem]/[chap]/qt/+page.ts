import {
  get_nctext_btran,
  get_nctext_qtran,
  get_nctext_hviet,
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

async function load_data({ spath, rmode }: CV.Chopts, fetch: CV.Fetch) {
  if (!spath) return { lines: [], mtime: 0, tspan: 0 }

  switch (rmode) {
    case 'be_zv':
      return await get_nctext_btran(spath, true, 'force-cache', fetch)
    case 'qt_v1':
      return await get_nctext_qtran(spath, 'force-cache', fetch)

    // case 'hviet':
    default:
      const data = await get_nctext_hviet(spath, true, 'force-cache', fetch)
      const { hviet, tspan, mtime, error } = data
      const lines = hviet.map((hvarr) => gen_hviet_text(hvarr, true))
      return { lines, hviet, tspan, mtime, error }
  }
}
