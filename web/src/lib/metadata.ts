export function head_link(text: string, icon: string, href: string, opts = {}) {
  return { ...opts, text, icon, href }
}

export function head_btn(text: string, icon: string, kbd = '', opts = {}) {
  return { ...opts, text, icon, 'data-kbd': kbd }
}
