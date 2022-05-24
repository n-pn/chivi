export function nvinfo_bar(nvinfo: CV.Nvinfo, extra?: object) {
  const opts = { href: `/-${nvinfo.bslug}`, kind: 'title' }
  if (extra) Object.assign(opts, extra)

  return [nvinfo.btitle_vi, 'book', opts]
}
