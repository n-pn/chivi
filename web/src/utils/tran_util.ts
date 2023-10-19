import { btran_text } from './qtran_utils/btran_free'

export interface FileReqInit extends CV.Rdopts {
  force?: boolean
}

export async function call_bt_zv_text(
  input: string[],
  { fpath, force = false }: FileReqInit,
  rinit: RequestInit = { cache: 'force-cache' },
  fetch = globalThis.fetch
): Promise<CV.Qtdata> {
  const start = performance.now()
  const lines = await btran_text(input)

  if (lines.length > 0) {
    console.log('successful using browser to translate from bing')
    const tspan = performance.now() - start
    // TODO: save to server
    return { lines, tspan }
  }

  const url = `/_sp/btran?fpath=${fpath}&force=${force}`
  const res = await fetch(url, rinit)

  if (res.ok) return await res.json()
  return { lines: [], tspan: 0, error: await res.text() }
}

export async function call_bt_zv_file(
  { fpath, force = false }: FileReqInit,
  rinit: RequestInit = { cache: 'force-cache' },
  fetch = globalThis.fetch
): Promise<CV.Qtdata> {
  const url = `/_sp/btran?fpath=${fpath}&force=${force}`
  const res = await fetch(url, rinit)

  if (res.ok) return await res.json()
  return { lines: [], tspan: 0, error: await res.text() }
}

export async function call_qt_v1_file(
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
): Promise<string[][]> {
  const url = `/_ai/qt/hviet?fpath=${fpath}`
  const res = await fetch(url, rinit)
  if (!res.ok) return undefined

  const lines = (await res.text()).split('\n')
  return lines.map((line: string) => line.match(/[\s\u200b].[^\s\u200b]*/g))
}

export async function call_mt_ai_file(
  { fpath, pdict = 'combine', mt_rm = 'mtl_1', force = false }: FileReqInit,
  rinit: RequestInit = { cache: 'force-cache' },
  fetch = globalThis.fetch
): Promise<CV.Mtdata> {
  const url = `/_ai/qtran?fpath=${fpath}&pdict=${pdict}&_algo=${mt_rm}&force=${force}`
  const res = await fetch(url, rinit)

  if (!res.ok) return { lines: [], tspan: 0, error: await res.text() }
  return await res.json()
}

export async function from_custom_gpt(
  input: string,
  rinit: RequestInit = { cache: 'force-cache' },
  fetch = globalThis.fetch
) {
  rinit.method = 'POST'
  rinit.body = input
  const res = await fetch('/_sp/c_gpt', rinit)
  return await res.text()
}
