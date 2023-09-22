import { local_get } from '$lib/vcache'

export async function get_nctext_btran(
  zpath: string,
  reuse = true,
  force = false,
  fetch = globalThis.fetch
): Promise<CV.Qtdata> {
  const c_key = `bv1:nc:${zpath}`
  return await local_get<CV.Qtdata>(c_key, reuse, async () => {
    const url = `/_sp/btran?zpath=${zpath}&force=${force}`
    const res = await fetch(url, { method: 'GET' })

    if (res.ok) return await res.json()
    return { lines: [], error: await res.text() }
  })
}

export async function get_nctext_qtran(
  zpath: string,
  reuse = true,
  force = false,
  fetch = globalThis.fetch
): Promise<CV.Qtdata> {
  const c_key = `m1:1:nc:${zpath}`

  return await local_get<CV.Qtdata>(c_key, reuse, async () => {
    if (!force) return { lines: [], error: 'n/a' }

    const wn_id = zpath.split('/')[0]
    const url = `/_m1/qtran?zpath=${zpath}&wn_id=${wn_id}&type=nctext`
    const res = await fetch(url, { method: 'GET' })

    if (res.ok) return await res.json()
    return { lines: [], error: await res.text() }
  })
}

export async function get_nctext_hviet(
  zpath: string,
  reuse: boolean = true,
  w_raw: boolean = false,
  fetch = globalThis.fetch
): Promise<CV.Hvdata> {
  const c_key = `hv:1:nc:${zpath}:${w_raw}`
  return await local_get<CV.Hvdata>(c_key, reuse, async () => {
    const url = `/_ai/hviet?zpath=${zpath}&w_raw=${w_raw}&ftype=nctext`
    const res = await fetch(url, { method: 'GET' })
    if (res.ok) return await res.json()
    console.log('error!')

    return { hviet: [], error: await res.text() }
  })
}

export async function get_nctext_mtran(
  zpath: string,
  reuse: boolean = true,
  force: boolean = false,
  _algo: string = 'avail',
  fetch = globalThis.fetch
): Promise<CV.Mtdata> {
  const c_key = `mt:1:nc:${zpath}:${_algo}`

  return await local_get<CV.Mtdata>(c_key, reuse, async () => {
    const pdict = 'book/' + zpath.split('/')[0]

    const url = `/_ai/qtran?cpath=${zpath}&pdict=${pdict}&_algo=${_algo}&force=${force}`
    const res = await fetch(url, { method: 'GET' })

    if (res.ok) return await res.json()
    return { lines: [], error: await res.text() }
  })
}
