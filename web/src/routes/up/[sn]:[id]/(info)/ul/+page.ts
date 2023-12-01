import type { PageLoad } from './$types'
import { redirect } from '@sveltejs/kit'

export const load = (async ({ params }) => {
  const { sn, id } = params
  throw redirect(300, `/ts/up${sn}/${id}/+text`)
}) satisfies PageLoad
