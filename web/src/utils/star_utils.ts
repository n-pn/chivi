export function gen_stars(rating: number, voters: number) {
  if (voters <= 10) return []

  const output = ['⭐']

  if (rating > 1.2) output.push('⭐')
  if (rating > 3.7) output.push('⭐')
  if (rating > 6.2) output.push('⭐')
  if (rating > 8.7) output.push('⭐')

  return output.join('')
}

export function rating_to_stars(rating: number) {
  if (rating < 1.25) return 1
  if (rating < 3.75) return 2
  if (rating < 6.25) return 3
  if (rating < 8.75) return 4
  return 5
}
