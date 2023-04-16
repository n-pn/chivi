export function debounce(
  func: { (input: string): Promise<void>; apply?: any },
  timeout = 300
) {
  let timer: number // | string | NodeJS.Timeout
  return (...args: any) => {
    clearTimeout(timer)
    // prettier-ignore
    timer = setTimeout(() => { func.apply(this, args) }, timeout)
  }
}

export function sync_scroll(source?: HTMLElement, target?: HTMLElement) {
  if (!source || !target) return

  // prettier-ignore
  const scrollTop = (source.scrollTop / source.scrollHeight) * target.scrollHeight

  const onscroll = target.onscroll
  target.onscroll = null

  target.scrollTop = Math.round(scrollTop)
  target.onscroll = onscroll
}
