export function find_last<T>(input: T[], callback: (x: T) => boolean) {
  for (let i = input.length - 1; i >= 0; i--) {
    const item = input[i]
    if (callback(item)) return item
  }

  return undefined
}
