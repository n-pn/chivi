import type { PageLoad } from './$types'

export const load = (async ({ fetch }) => {
  const files = await fetch('/_mt/specs').then((r) => r.json())
  console.log(files)
  return { files }
}) satisfies PageLoad
