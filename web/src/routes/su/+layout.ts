import { redirect } from '@sveltejs/kit'
import type { LayoutLoad } from './$types'

export const load = (async ({ parent }) => {
  const { _user } = await parent()
  if (_user && _user.privi > 3) return
  else throw redirect(307, '/')
}) satisfies LayoutLoad
