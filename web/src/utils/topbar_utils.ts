export function nvinfo_bar({ id, vtitle }: CV.Wninfo, extra?: App.HeadItem) {
  const opts = { 'href': `/wn/${id}`, 'data-kind': 'title' }
  if (extra) Object.assign(opts, extra)
  return { text: vtitle, icon: 'book', ...opts }
}
