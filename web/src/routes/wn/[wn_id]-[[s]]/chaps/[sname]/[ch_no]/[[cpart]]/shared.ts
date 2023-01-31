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
