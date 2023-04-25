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

export const recrawl_chap = async ({ nvinfo, wnchap, curr_seed }) => {
  const wn_id = nvinfo.id
  const sname = curr_seed.sname
  const ch_no = wnchap.ch_no

  const href = `/_wn/chaps/${wn_id}/${sname}/${ch_no}?load_mode=2`

  try {
    return await fetch(href).then((r) => r.json())
  } catch (ex) {
    console.log(ex)
    return null
  }
}
