import type { Ctree } from '$lib/mt_data_2'

export type CtreeRes = { cdata: Array<Ctree>; tspan: number; error?: string }
export type VtextRes = { cdata: Array<string>; tspan: number; error?: string }

const hviet_cache = new Map<string, CtreeRes>()
const btran_cache = new Map<string, VtextRes>()

export async function get_wntext_hviet(
  zpath: string,
  force = false,
  fetch = globalThis.fetch
): Promise<CtreeRes> {
  const cached = force ? undefined : hviet_cache.get(zpath)
  if (cached) return cached

  const url = `/_ai/qt/hviet?zpath=${zpath}&force=${force}`
  const res = await fetch(url, { method: 'GET' })

  if (!res.ok) return { cdata: [], tspan: 0, error: await res.text() }

  const cdata = await res.json()
  if (!cdata.error) hviet_cache.set(zpath, cdata)

  return cdata
}

export async function get_wntext_btran(
  zpath: string,
  force = false,
  fetch = globalThis.fetch
): Promise<VtextRes> {
  const cached = force ? undefined : btran_cache.get(zpath)
  if (cached) return cached

  const url = `/_ai/qt/btran?zpath=${zpath}&force=${force}`
  const res = await fetch(url, { method: 'GET' })

  if (!res.ok) return { cdata: [], tspan: 0, error: await res.text() }

  const cdata = await res.json()
  if (!cdata.error) btran_cache.set(zpath, cdata)

  return cdata
}
