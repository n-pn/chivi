export function kit_chap_url(bslug, { sname, uslug, chidx, cpart }) {
  const url = `/-${bslug}/-${sname}/-${uslug}-${chidx}`
  return cpart > 0 ? url + '.' + cpart : url
}
