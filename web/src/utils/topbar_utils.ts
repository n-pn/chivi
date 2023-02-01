export function nvinfo_bar(nvinfo: CV.Nvinfo, extra?: App.HeadItem) {
  const opts = { 'href': `/wn/${nvinfo.bslug}`, 'data-kind': 'title' }
  if (extra) Object.assign(opts, extra)
  return { text: nvinfo.btitle_vi, icon: 'book', ...opts }
}
