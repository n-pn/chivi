// import { api_call } from '$lib/api_call'

export const load = async ({ fetch, url }) => {
  const id = url.searchParams.get('id')
  if (!id) return { form: undefined }
  const form = await fetch(`/api/crits/${id}/edit`).then((r) => r.json())
  return { form: form }
}
