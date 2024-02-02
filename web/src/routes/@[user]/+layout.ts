import { api_get } from '$lib/api_call'
import type { LayoutData } from './$types'

export const load = (async ({ fetch, params: { user } }) => {
  return {
    viuser: api_get<CV.Viuser>(`/_db/users/${user}`, fetch),
    _navs: [{ href: `@${user}`, text: `Trang cá nhân của @${user}` }],
  }
}) satisfies LayoutData
