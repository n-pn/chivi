import { redirect } from '@sveltejs/kit'
import type { PageLoad } from './$types'

export const load = (async ({ params }) => {
  const { wn } = params
  throw redirect(300, `/ts/wn~avail/${wn}/+text`)
}) satisfies PageLoad
