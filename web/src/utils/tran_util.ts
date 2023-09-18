import { local_get } from '$lib/vcache'

export type HvietRes = {
  hviet: Array<[string, string]>
  tspan: number
  ztext?: Array<string>
  error?: string
}

export type VtextRes = { cdata: Array<string>; tspan: number; error?: string }

const btran_cache = new Map<string, VtextRes>()

export async function get_wntext_hviet(
  zpath: string,
  force: boolean = false,
  w_raw: boolean = false,
  fetch = globalThis.fetch
): Promise<HvietRes> {
  return await local_get<HvietRes>(`hv:wn:${zpath}`, force, async () => {
    const url = `/_sp/hviet?zpath=${zpath}&ftype=nctext&w_raw=${w_raw}`
    const res = await fetch(url, { method: 'GET' })

    if (res.ok) return await res.json()
    return { hviet: [], tspan: 0, error: await res.text() }
  })
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
