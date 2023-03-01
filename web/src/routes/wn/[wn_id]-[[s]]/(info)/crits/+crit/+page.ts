import { api_get } from '$lib/api_call'

import type { PageLoad } from './$types'

export const load = (async ({ fetch, url }) => {
  const id = +url.searchParams.get('id')
  if (!id) return { form: undefined }

  const path = `/_db/crits/${id}/edit`
  const form = await api_get<CV.VicritForm>(path, fetch)

  console.log(form)
  return { form: form }
}) satisfies PageLoad
