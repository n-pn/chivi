import type { PageLoad } from './$types'

export const load = (({ url }) => {
  return { email: url.searchParams.get('email') || '' }
}) satisfies PageLoad
