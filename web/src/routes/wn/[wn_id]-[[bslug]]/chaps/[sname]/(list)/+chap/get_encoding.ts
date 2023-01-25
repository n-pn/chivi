export const get_encoding = async (buffer: ArrayBuffer) => {
  const headers = { 'content-type': 'text/plain' }

  const opts = { method: 'POST', body: buffer.slice(0, 200), headers }
  const res = await fetch('/_sp/chardet', opts)

  const res_data = await res.text()
  if (res.ok) return res_data

  console.log('error', res_data)
  return 'UTF-8'
}
