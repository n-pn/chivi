import type { PageLoad } from '../../$types'

export const load = (({ url }) => {
  const config = url.searchParams.get('config') || 'hk2s'
  return { config }
}) satisfies PageLoad
