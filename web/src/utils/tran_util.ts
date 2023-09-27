export type FileReqInit = {
  fpath: string
  ftype: string
  force: boolean
  pdict?: string
  wn_id?: number
  m_alg?: string
}

export async function call_btran_file(
  { fpath, ftype = 'nc', force = false }: FileReqInit,
  rinit: RequestInit = { cache: 'force-cache' },
  fetch = globalThis.fetch
): Promise<CV.Qtdata> {
  const url = `/_sp/btran?fpath=${fpath}&ftype=${ftype}&force=${force}`
  const res = await fetch(url, rinit)

  if (res.ok) return await res.json()
  return { lines: [], tspan: 0, error: await res.text() }
}

export async function call_qtran_file(
  { fpath, ftype = 'nc', wn_id = 0 }: FileReqInit,
  rinit: RequestInit = { cache: 'force-cache' },
  fetch = globalThis.fetch
): Promise<CV.Qtdata> {
  wn_id ||= +fpath.split('/')[0]
  const url = `/_m1/qtran?fpath=${fpath}&ftype=${ftype}&wn_id=${wn_id}`
  const res = await fetch(url, rinit)

  if (res.ok) return await res.json()
  return { lines: [], tspan: 0, error: await res.text() }
}

export async function call_hviet_file(
  { fpath, ftype = 'nc' }: FileReqInit,
  rinit: RequestInit = { cache: 'force-cache' },
  fetch = globalThis.fetch
): Promise<CV.Hvdata> {
  const url = `/_ai/hviet?fpath=${fpath}&ftype=${ftype}`
  const res = await fetch(url, rinit)

  if (res.ok) return await res.json()
  return { hviet: [], tspan: 0, error: await res.text() }
}

export async function call_mtran_file(
  { fpath, ftype = 'nc', force = false, m_alg, pdict }: FileReqInit,
  rinit: RequestInit = { cache: 'force-cache' },
  fetch = globalThis.fetch
): Promise<CV.Mtdata> {
  m_alg ||= 'avail'
  pdict ||= 'book/' + fpath.split('/')[0]

  const url = `/_ai/qtran?fpath=${fpath}&ftype=${ftype}&pdict=${pdict}&_algo=${m_alg}&force=${force}`
  const res = await fetch(url, rinit)

  if (!res.ok) return { lines: [], tspan: 0, error: await res.text() }
  return await res.json()
}

export async function from_custom_gpt(input: string, fetch = globalThis.fetch) {
  const res = await fetch('/_sp/c_gpt', { method: 'POST', body: input })
  return await res.text()
}
