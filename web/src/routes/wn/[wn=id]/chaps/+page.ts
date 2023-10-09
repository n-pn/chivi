import { redirect } from '@sveltejs/kit'
import { seed_path, _pgidx } from '$lib/kit_path'

export async function load({ parent }) {
  const { nvinfo, ubmemo } = await parent()
  let { chidx = 1 } = ubmemo
  const location = seed_path(nvinfo.bslug, '~avail', _pgidx(chidx))
  throw redirect(302, location)
}
