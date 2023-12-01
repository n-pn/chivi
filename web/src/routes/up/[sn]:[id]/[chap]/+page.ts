import type { PageLoad } from './$types'
import { redirect } from '@sveltejs/kit'

export const load = (async ({ params: { sn, id, chap }, url }) => {
  throw redirect(300, `/ts/up${sn}/${id}/c${chap}${url.search}`)
}) satisfies PageLoad
