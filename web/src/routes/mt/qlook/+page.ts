import type { PageLoad } from './$types'

export const load = (({ url }) => {
  const word = url.searchParams.get('kw') || ''
  return { word }
}) satisfies PageLoad
