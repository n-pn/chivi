import { api_path } from '$lib/api_call'
import type { PageLoad } from './$types'

export const load: PageLoad = async ({ fetch, url: { searchParams } }) => {
  const path = api_path('yscrits.index', null, searchParams, { lm: 10 })
  const data = await fetch(path).then((r) => r.json())
  return data
}
