/** @type {import('@sveltejs/kit').ParamMatcher} */
export function match(param: string) {
  return /^\d+/.test(param)
}
