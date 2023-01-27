import type { PageLoad } from './$types'

export const load = (({ url }) => {
  return {
    start: +url.searchParams.get('start') || 1,
  }
}) satisfies PageLoad
