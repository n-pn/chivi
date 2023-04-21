import type { PageData } from './$types'

export function api_chap_url(
  wn_id: number,
  sname: string,
  ch_no: number,
  cpart: number = 1,
  regen = false
) {
  if (cpart < 1) cpart = 1
  const base = `/_wn/chaps/${wn_id}/${sname}/${ch_no}/${cpart}`
  return regen ? base + '?load_mode=1' : base
}

export const recrawl_chap = async (data: PageData, load_mode = 2) => {
  const wn_id = data.nvinfo.id
  const sname = data.curr_seed.sname
  const ch_no = data.curr_chap.chidx
  const cpart = data.chap_data.cpart

  const href = `/_wn/chaps/${wn_id}/${sname}/${ch_no}/${cpart}?load_mode=${load_mode}`

  try {
    return await fetch(href).then((r) => r.json())
  } catch (ex) {
    console.log(ex)
    return null
  }
}
