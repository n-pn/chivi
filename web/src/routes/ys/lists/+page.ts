import { api_path, api_get } from '$lib/api_call'

export async function load({ fetch, url: { searchParams } }) {
  const path = api_path('yslists.index', {}, searchParams, { lm: 10 })
  const data = await api_get<CV.YslistList>(path, fetch)

  const params = Object.fromEntries(searchParams)
  return { ...data, params: params }
}
