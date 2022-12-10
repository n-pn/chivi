import { crit_edit } from '$lib/vi_api'

export const load = async ({ fetch, url }) => {
  const id = url.searchParams.get('id')
  return { form: id ? await crit_edit(+id, fetch) : undefined }
}
