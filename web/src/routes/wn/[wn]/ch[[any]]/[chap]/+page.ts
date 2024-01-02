import { redirect } from '@sveltejs/kit'
import type { PageLoad } from './$types'

export const load = (async ({ params, url }) => {
  const { wn, chap } = params
  const wn_id = parseInt(wn, 10)
  throw redirect(300, `/ts/wn~avail/${wn_id}/c${chap}${url.search}`)
}) satisfies PageLoad
