const key_map = {
  ArrowLeft: '←',
  ArrowRight: '→',
  ArrowUp: '↑',
  ArrowDown: '↓',
}

export function map_keypress(evt: KeyboardEvent, on_input = false) {
  const key = evt.key

  if (key == 'Escape') return 'esc'
  if (key == 'Enter') return prefix_key(evt, '↵')

  if (on_input && !evt.altKey) return
  if (key == 'Shift' || key == 'Control') return

  return prefix_key(evt, key_map[key] || key)
}

function prefix_key({ shiftKey, ctrlKey }, key: string) {
  if (shiftKey) key = '⇧' + key
  if (ctrlKey) key = '⌃' + key
  return key
}

export function trigger_click(evt: KeyboardEvent, sel: string, alt: string) {
  const elem = document.querySelector(sel) || document.querySelector(alt)
  if (!(elem instanceof HTMLElement)) return
  evt.preventDefault()
  evt.stopPropagation()
  elem.click()
}
