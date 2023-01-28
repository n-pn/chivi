export function api_chap_url(
  wn_id: number,
  sname: string,
  ch_no: number,
  cpart = 0,
  regen = false
) {
  const base = `/_wn/chaps/${wn_id}/${sname}/${ch_no}/${cpart - 1}`
  return regen ? base + '?load_mode=1' : base
}
