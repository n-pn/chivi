import type { PageLoad } from './$types'

export const load = (async ({ fetch, params }) => {
  const cases = await fetch(`/_mt/specs/${params.name}`).then((r) => r.json())
  return { cases }
}) satisfies PageLoad
