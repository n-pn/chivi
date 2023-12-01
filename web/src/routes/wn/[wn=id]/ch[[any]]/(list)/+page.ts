import { redirect } from '@sveltejs/kit'
import type { PageLoad } from './$types'

export const load = (async ({ params }) => {
  const wn_id = parseInt(params.wn)
  throw redirect(300, `/ts/wn~avail/${wn_id}`)
}) satisfies PageLoad
