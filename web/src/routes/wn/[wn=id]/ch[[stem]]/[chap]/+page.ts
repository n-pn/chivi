import { error } from '@sveltejs/kit'
import type { PageLoad } from './$types'
import type { Cdata } from '$lib/mt_data_2'

export const load = (async ({ fetch, parent }) => {
  const { rdata, xargs } = await parent()
  return await load_data(rdata, xargs, fetch)
}) satisfies PageLoad

type Xargs = { wn_id: number; cpart: number; rtype: string; rmode: string }
type Cvmtl = { lines: Array<Cdata>; ctime: number; _algo?: string }

const headers = { 'Content-Type': 'application/json' }

async function load_data(rdata: CV.Chdata, xargs: Xargs, fetch: CV.Fetch) {
  const cpath = `${rdata.cbase}-${xargs.cpart}`

  const pdict = `book/$${xargs.wn_id}`
  const url = `/_ai/mt/wnchap?cpath=${cpath}&pdict=${pdict}&_algo=${xargs.rmode}`
  const res = await fetch(url, { headers: headers })
  if (!res.ok) throw error(res.status, await res.text())
  return (await res.json()) as Cvmtl
}
