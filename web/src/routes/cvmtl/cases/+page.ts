import type { PageLoad } from './$types'

export const load = (async ({ fetch }) => {
  const files = await fetch('/_m2/specs').then((r) => r.json())
  return { files }
}) satisfies PageLoad
