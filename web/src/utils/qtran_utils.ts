import { gtran_text } from './qtran_utils/gg_tran'

export const call_qtran = async (
  body: string,
  type: string,
  opts: Record<string, any> = {}
): Promise<string[] | CV.Cvtree[]> => {
  const { pdict = 'combine', regen = 0, h_sep = 1, l_sep = 0, otype = 'mtl' } = opts
  if (type == 'gg_zv') return await gtran_text(body)
  const url = `/_sp/qtran/${type}?pd=${pdict}&rg=${regen}&hs=${h_sep}&ls=${l_sep}&op=${otype}`

  const start = performance.now()
  const res = await fetch(url, { method: 'POST', body })
  if (!res.ok) return [await res.text()]

  let vtran: string[] | CV.Cvtree[]

  if (type.startsWith('mtl') && otype == 'mtl') {
    vtran = (await res.json()) as CV.Cvtree[]
  } else {
    vtran = (await res.text()).trim().split('\n')
  }

  const spent = performance.now() - start
  console.log(`- ${type}: ${body.length} chars, ${spent} milliseconds`)

  if (!res.ok) return []
  return vtran
}
