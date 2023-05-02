import { redirect } from '@sveltejs/kit'

export const load = ({ url }) => {
  throw redirect(304, url.pathname + '/bants')
}
