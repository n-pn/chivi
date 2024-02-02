import { redirect } from '@sveltejs/kit'
import type { PageData } from './$types'

export const load = (async () => {
  throw redirect(300, '/_u/login')
}) satisfies PageData
