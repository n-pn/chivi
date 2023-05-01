import { redirect } from '@sveltejs/kit'

export const load = ({ url }) => {
  throw redirect(304, url.pathname + '/1-mt')
}
