const BASIS_32 = 0x811c9dc5n
const PRIME_32 = 16777619n
const MASK_32 = 4294967295n

const BASIS_64 = 0xcbf29ce484222325n
const PRIME_64 = 1099511628211n
const MASK_64 = 18446744073709551615n

export function fnv_1a_32(inp: string, hash = BASIS_32) {
  for (const byte of Buffer.from(inp)) {
    hash = hash ^ BigInt(byte)
    hash = hash * PRIME_32
    hash = hash & MASK_32
  }

  return hash
}

export function fnv_1a_64(inp: string, hash = BASIS_64) {
  for (const byte of Buffer.from(inp)) {
    hash = hash ^ BigInt(byte)
    hash = hash * PRIME_64
    hash = hash & MASK_64
  }
  return hash
}
