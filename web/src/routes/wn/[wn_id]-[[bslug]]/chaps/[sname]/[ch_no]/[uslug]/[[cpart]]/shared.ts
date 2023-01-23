export function api_chap_url(
  sname: string,
  s_bid: number,
  ch_no: number,
  cpart = 0,
  regen = false
) {
  const base = `/_wn/chaps/${sname}/${s_bid}/${ch_no}/${cpart - 1}`
  return regen ? base + '?load_mode=1' : base
}
