export const copy_to_clipboard = (text: string) => {
  navigator.clipboard.writeText(text)
}
