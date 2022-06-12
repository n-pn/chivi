export function hash_str(s: string) {
  var hash = 0

  for (let i = 0; i < s.length; i++) {
    const chr = s.charCodeAt(i)
    hash = (hash << 5) - hash + chr
    hash |= 0
  }

  if (hash < 0) hash = -hash
  return hash.toString(32)
}
