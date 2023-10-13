import { redirect } from '@sveltejs/kit'

export const load = ({ url }) => {
  throw redirect(300, url.pathname + '/bants')
}
