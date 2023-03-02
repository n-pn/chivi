import type { PageLoad } from './$types'

export const load = (({ url }) => {
  const word = url.searchParams.get('word') || ''
  return { word }
}) satisfies PageLoad
