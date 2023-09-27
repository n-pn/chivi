const headers = { 'content-type': 'text/plain' }

export const get_encoding = async (buffer: ArrayBuffer) => {
  const opts = { method: 'POST', body: buffer.slice(0, 1000), headers }
  return await fetch('/_sp/chardet', opts).then((r) => r.text())
}
