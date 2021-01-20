export function capitalize(str) {
  return str.charAt(0).toUpperCase() + str.slice(1)
}

export function titleize(str, count = 9) {
  const res = str.split(' ')
  if (count > res.length) count = res.length

  for (let i = 0; i < count; i++) res[i] = capitalize(res[i])
  for (let i = count; i < res.length; i++) res[i] = res[i].toLowerCase()

  return res.join(' ')
}
