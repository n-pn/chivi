import { api_path, api_get } from '$lib/api_call'

interface YslistData extends CV.Paginate {
  ylist: CV.Yslist
  yuser: CV.Ysuser

  crits: CV.Yscrit[]
  books: Record<number, CV.Crbook>
}

export function load({ fetch, params, url: { searchParams } }) {
  const list = params.list.split('-')[0]
  const path = api_path('yslists.show', list, searchParams)
  return api_get<YslistData>(path, fetch)
}
