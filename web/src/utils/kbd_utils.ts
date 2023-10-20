export function map_keypress(evt: KeyboardEvent, on_input = false) {
  console.log(evt.key)
  switch (evt.key) {
    case 'Escape':
      return 'esc'

    case 'Enter':
      return prefix_key(evt, '↵')

    case 'ArrowLeft':
      if (on_input && !evt.altKey) return
      return prefix_key(evt, '←')

    case 'ArrowRight':
      if (on_input && !evt.altKey) return
      return prefix_key(evt, '→')

    case 'ArrowUp':
      if (on_input && !evt.altKey) return
      return prefix_key(evt, '↑')

    case 'ArrowDown':
      if (on_input && !evt.altKey) return
      return prefix_key(evt, '↓')

    case 'Shift':
    case 'Ctrl':
      return

    default:
      if (on_input && !evt.altKey) return
      return prefix_key(evt, evt.key)
  }
}

function prefix_key({ shiftKey, ctrlKey }, key: string) {
  if (shiftKey) key = '⇧' + key
  if (ctrlKey) key = '⌃' + key
  return key
}

export function trigger_click(
  evt: KeyboardEvent,
  query: string,
  query_alt: string
) {
  const elem: HTMLElement =
    document.querySelector(query) || document.querySelector(query_alt)
  if (!elem) return false

  evt.preventDefault()
  evt.stopPropagation()
  elem.click()
}
