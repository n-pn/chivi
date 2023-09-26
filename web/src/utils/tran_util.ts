export async function get_nctext_btran(
  zpath: string,
  force = false,
  cache: RequestCache = 'force-cache',
  fetch = globalThis.fetch
): Promise<CV.Qtdata> {
  const url = `/_sp/btran?zpath=${zpath}&force=${force}`
  const res = await fetch(url, { cache })

  if (res.ok) return await res.json()
  return { lines: [], tspan: 0, error: await res.text() }
}

export async function get_nctext_qtran(
  zpath: string,
  cache: RequestCache = 'force-cache',
  fetch = globalThis.fetch
): Promise<CV.Qtdata> {
  const wn_id = zpath.split('/')[0]
  const url = `/_m1/qtran?zpath=${zpath}&wn_id=${wn_id}&type=nctext`
  const res = await fetch(url, { cache })

  if (res.ok) return await res.json()
  return { lines: [], tspan: 0, error: await res.text() }
}

export async function get_nctext_hviet(
  zpath: string,
  w_raw: boolean = false,
  cache: RequestCache = 'force-cache',
  fetch = globalThis.fetch
): Promise<CV.Hvdata> {
  const url = `/_ai/hviet?zpath=${zpath}&w_raw=${w_raw}&ftype=nctext`
  const res = await fetch(url, { cache })

  if (res.ok) return await res.json()
  return { hviet: [], tspan: 0, error: await res.text() }
}

export async function get_nctext_mtran(
  zpath: string,
  force: boolean = false,
  _algo: string = 'avail',
  cache: RequestCache = 'force-cache',
  fetch = globalThis.fetch
): Promise<CV.Mtdata> {
  const pdict = 'book/' + zpath.split('/')[0]

  const url = `/_ai/qtran?cpath=${zpath}&pdict=${pdict}&_algo=${_algo}&force=${force}`
  const res = await fetch(url, { cache })

  if (!res.ok) return { lines: [], tspan: 0, error: await res.text() }

  return await res.json()
}

export async function from_custom_gpt(input: string, fetch = globalThis.fetch) {
  const res = await fetch('/_sp/c_gpt', { method: 'POST', body: input })
  return await res.text()
}
