import { error } from '@sveltejs/kit'
import type { PageLoad } from './$types'
import type { Cdata } from '$lib/mt_data_2'

export const load = (async ({ url, params: { wn }, fetch, parent }) => {
  const wn_id = parseInt(wn, 10)
  const { rdata } = await parent()
  return await load_data(rdata, wn_id, url.searchParams, fetch)
}) satisfies PageLoad

const headers = { 'Content-Type': 'application/json' }

async function load_data(
  rdata: CV.Chdata,
  wn_id: number,
  param: URLSearchParams,
  fetch = globalThis.fetch
) {
  const cpart = param.get('part') || 1
  const cpath = `${rdata.cbase}-${cpart}`

  const rtype = param.get('type')
  let rmode = param.get('mode')

  switch (rtype) {
    case 'qt':
      rmode ||= 'mt_v1'
      return { cpart, rtype, rmode, lines: [], ctime: 0 }

    case 'tl':
      rmode ||= 'basic'
      return { cpart, rtype, rmode, lines: [], ctime: 0 }

    case 'cf':
      rmode ||= 'edit_raw'
      return { cpart, rtype, rmode, lines: [], ctime: 0 }

    default:
      rmode ||= 'avail'
      const [lines, ctime] = await call_mt_tran(cpath, wn_id, rmode, fetch)
      return { cpart, rtype: 'mt', rmode, lines, ctime }
  }
}

async function call_mt_tran(
  cpath: string,
  wn_id: number,
  _algo: string,
  fetch = globalThis.fetch
) {
  const url = `/_ai/mt/wnchap?cpath=${cpath}&pdict=book/${wn_id}&_algo=${_algo}`
  const res = await fetch(url, { headers: headers })
  if (!res.ok) throw error(res.status, await res.text())
  return (await res.json()) as [Array<Cdata>, number]
}

function get_type_and_mode(search: URLSearchParams) {
  let rtype = search.get('type')

  switch (rtype) {
    case 'qt':
      return [rtype, 'mt_v1']

    case 'tl':
      return [rtype, 'basic']

    case 'cf':
      return [rtype, search.get('mode')]

    default:
      return ['mt', search.get('mode') || 'avail']
  }
}
