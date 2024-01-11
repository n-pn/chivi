import { gtran_text } from './qtran_utils/gg_tran'
import { ms_api_key } from './qtran_utils/ms_tran'

export const call_qtran = async (
  body: string,
  type: string,
  opts = {},
  redo = false
): Promise<[string[], number]> => {
  if (type == 'gg_zv') return [await gtran_text(body), 0]
  let url = `/_sp/qtran/${type}?redo=${redo}`

  if (type.startsWith('ms')) {
    url += `&opts=${await ms_api_key()}`
  } else if (type == 'qt_v1') {
    const wn_id = opts['wn_id'] || 0
    const title = opts['title'] || 1
    url += `&opts=${wn_id},${title}`
  }

  const start = performance.now()
  const res = await fetch(url, { method: 'POST', body })
  const vtran = await res.text()

  const spent = performance.now() - start
  console.log(`- ${type}: ${body.length} chars, ${spent} milliseconds`)

  if (!res.ok) return [[], spent]
  return [vtran.trim().split('\n'), spent]
}

export const call_mtran = async (
  body: string,
  type: string,
  opts = {},
  redo = false
): Promise<[CV.Cvtree[], number]> => {
  let url = `/_sp/qtran/${type}?redo=${redo}`

  const pdict = opts['pdict'] || 'combine'
  const title = opts['title'] || 1
  url += `&opts=${pdict},${title}`

  const start = performance.now()

  const res = await fetch(url, { method: 'POST', body })
  const mdata = await res.json()

  const spent = performance.now() - start
  console.log(`- ${type}: ${body.length} chars, ${spent} milliseconds`)

  if (!res.ok) return [[], spent]
  return [mdata.lines as CV.Cvtree[], spent]
}
