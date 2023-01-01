import { redirect } from '@sveltejs/kit'

export const load = async ({ parent }) => {
  const { _user } = await parent()
  if (_user?.privi > -1) throw redirect(300, '/')
}
