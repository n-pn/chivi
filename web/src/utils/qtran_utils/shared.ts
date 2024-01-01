export const send_vcache = (type: string, data: Record<string, any>) => {
  const init = { method: 'POST', body: JSON.stringify(data) }
  fetch(`/_sp/vcache/${type}`, init).catch((x) => console.log(x))
}

export const detitlize = (text: string) => {
  return text.charAt(0).toLowerCase() + text.substring(1)
}
