import type { PageLoad } from './$types'

export const load = (async ({ fetch, parent, depends }) => {
  const { xargs } = await parent()
  depends(`up:qt:${xargs.rmode}`)

  xargs.rtype = 'qt'
  return { xargs, dirty: true }
}) satisfies PageLoad
