const AVG = 3000
const MAX = 4500

export function split_chap(paras: string[]) {
  if (paras.length == 0) return []

  const sizes = paras.map((x) => x.length)
  const c_len = sizes.reduce((a, b) => a + b, 0)

  if (c_len <= MAX) return [paras]

  const parts: string[][] = []

  const parts_count = Math.floor((c_len - 1) / AVG) + 1
  const limit = Math.round(c_len / parts_count)

  let count = 0

  let lines: string[] = []

  for (let i = 0; i < paras.length; i++) {
    lines.push(paras[i])
    count += sizes[i]

    if (count < limit) continue

    parts.push(lines)
    // prettier-ignore
    if (parts.length > 30) throw "Chương có quá nhiều đoạn, mời xem lại dữ liệu đầu vào!"

    lines = []
    count = 0
  }

  if (count > 0) parts.push(lines)
  return parts
}
