import { api_path, api_get } from '$lib/api_call'

interface ListData {
  yl_id: string
  ylist: CV.Yslist
  crits: CV.Yscrit[]
  books: Record<number, CV.Crbook>
  pgmax: number
  pgidx: number
}

export async function load({ fetch, params, url: { searchParams } }) {
  const list = params.list.split('-')[0]
  const path = api_path('yslists.show', list, searchParams)
  const data = await api_get<ListData>(path, null, fetch)
  return { ...data, _path: 'ylist_show' }
}
