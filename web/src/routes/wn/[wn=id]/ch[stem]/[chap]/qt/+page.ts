import {
  get_nctext_btran,
  get_nctext_qtran,
  get_nctext_hviet,
} from '$utils/tran_util'
import { gen_hviet_text } from '$lib/mt_data_2'

import type { PageLoad } from './$types'

export const load = (async ({ fetch, parent, depends }) => {
  const { rdata, xargs } = await parent()
  xargs.type = 'qt'
  depends(`wn:qt:${xargs.rmode}`)

  return await load_data(rdata, xargs, fetch)
}) satisfies PageLoad

async function load_data(rdata: CV.Chdata, xopts: CV.Chopts, fetch: CV.Fetch) {
  if (!rdata.cbase) return { lines: [], mtime: 0, tspan: 0 }
  const cpath = `${rdata.cbase}-${xopts.cpart}`

  switch (xopts.rmode) {
    case 'be_zv':
      return await get_nctext_btran(cpath, true, 'force-cache', fetch)
    case 'qt_v1':
      return await get_nctext_qtran(cpath, 'force-cache', fetch)

    // case 'hviet':
    default:
      const data = await get_nctext_hviet(cpath, true, 'force-cache', fetch)
      const { hviet, tspan, mtime, error } = data
      const lines = hviet.map((hvarr) => gen_hviet_text(hvarr, true))
      return { lines, tspan, mtime, error }
  }
}
