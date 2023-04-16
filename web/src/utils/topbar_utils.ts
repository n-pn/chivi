export function nvinfo_bar(nvinfo: CV.Wninfo, extra?: App.HeadItem) {
  const opts = { 'href': `/wn/${nvinfo.bslug}`, 'data-kind': 'title' }
  if (extra) Object.assign(opts, extra)
  return { text: nvinfo.vtitle, icon: 'book', ...opts }
}
