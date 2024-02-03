import type { PageLoad } from './$types'

export const load = (async ({ parent }) => {
  const { ustem } = await parent()

  return {
    ontab: 'bants',
    _meta: `Thảo luận - ${ustem.vname}`,
  }
}) satisfies PageLoad
