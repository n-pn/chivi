export function kit_chap_url(bslug, { sname, uslug, chidx, cpart }) {
  if (chidx == -1) chidx = 1
  const url = `/-${bslug}/-${sname}/-${uslug}-${chidx}`
  return cpart > 0 ? url + '.' + cpart : url
}
