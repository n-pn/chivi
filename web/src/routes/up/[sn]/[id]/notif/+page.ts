import type { PageLoad } from './$types'

export const load = (async ({ parent }) => {
  const { ustem } = await parent()

  return {
    ontab: 'notif',
    _meta: { title: `Thay đổi - ${ustem.vname}` },
  }
}) satisfies PageLoad
