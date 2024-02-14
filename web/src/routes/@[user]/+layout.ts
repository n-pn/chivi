import type { LayoutData } from './$types'

import { error } from '@sveltejs/kit'
import { api_get } from '$lib/api_call'

export const load = (async ({ fetch, params: { user } }) => {
  try {
    const vuser = await api_get<CV.Viuser>(`/_db/users/${user}`, fetch)

    return {
      vuser,
      _navs: [{ href: `@${user}`, text: `Trang cá nhân của @${user}` }],
    }
  } catch (ex) {
    throw error(404, 'Nguời dùng không tồn tại!')
  }
}) satisfies LayoutData
