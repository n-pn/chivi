export type FileReqInit = {
  fpath: string
  force: boolean
  pdict?: string
  wn_id?: number
  m_alg?: string
}

export async function call_btran_file(
  { fpath, force = false }: FileReqInit,
  rinit: RequestInit = { cache: 'force-cache' },
  fetch = globalThis.fetch
): Promise<CV.Qtdata> {
  const url = `/_sp/btran?fpath=${fpath}&force=${force}`
  const res = await fetch(url, rinit)

  if (res.ok) return await res.json()
  return { lines: [], tspan: 0, error: await res.text() }
}

export async function call_qtran_file(
  { fpath, wn_id = 0 }: FileReqInit,
  rinit: RequestInit = { cache: 'force-cache' },
  fetch = globalThis.fetch
): Promise<CV.Qtdata> {
  const url = `/_m1/qtran?fpath=${fpath}&wn_id=${wn_id}`
  const res = await fetch(url, rinit)

  if (res.ok) return await res.json()
  return { lines: [], tspan: 0, error: await res.text() }
}

export async function call_hviet_file(
  { fpath }: FileReqInit,
  rinit: RequestInit = { cache: 'force-cache' },
  fetch = globalThis.fetch
): Promise<CV.Hvdata> {
  const url = `/_ai/hviet?fpath=${fpath}`
  const res = await fetch(url, rinit)

  if (res.ok) return await res.json()
  return { hviet: [], tspan: 0, error: await res.text() }
}

export async function call_mtran_file(
  { fpath, pdict, force = false, m_alg = 'avail' }: FileReqInit,
  rinit: RequestInit = { cache: 'force-cache' },
  fetch = globalThis.fetch
): Promise<CV.Mtdata> {
  const url = `/_ai/qtran?fpath=${fpath}&pdict=${pdict}&_algo=${m_alg}&force=${force}`
  const res = await fetch(url, rinit)

  if (!res.ok) return { lines: [], tspan: 0, error: await res.text() }
  return await res.json()
}

export async function from_custom_gpt(input: string, fetch = globalThis.fetch) {
  const res = await fetch('/_sp/c_gpt', { method: 'POST', body: input })
  return await res.text()
}
