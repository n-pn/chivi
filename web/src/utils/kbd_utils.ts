export function map_keypress(evt: KeyboardEvent) {
  const tag_name = document.activeElement?.tagName
  const on_input = tag_name == 'TEXTAREA' || tag_name == 'INPUT'

  switch (evt.key) {
    case 'Escape':
      return 'esc'

    case 'Enter':
      return prefix_key(evt, '↵')

    case 'ArrowLeft':
      if (!evt.altKey) return
      return prefix_key(evt, '←')

    case 'ArrowRight':
      if (!evt.altKey) return
      return prefix_key(evt, '→')

    case 'ArrowUp':
      if (!evt.altKey) return
      return prefix_key(evt, '↑')

    case 'ArrowDown':
      if (!evt.altKey) return
      return prefix_key(evt, '↓')

    default:
      return on_input ? '' : prefix_key(evt, evt.key)
  }
}

function prefix_key({ shiftKey, ctrlKey }, key: string) {
  if (shiftKey) key = '⇧' + key
  if (ctrlKey) key = '⌃' + key
  return key
}

export function trigger_click(evt: KeyboardEvent, selector: string) {
  const elem: HTMLElement = document.querySelector(selector)
  if (!elem) return

  evt.preventDefault()
  evt.stopPropagation()
  elem.click()
}
