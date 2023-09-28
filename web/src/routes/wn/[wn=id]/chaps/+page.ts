import { redirect } from '@sveltejs/kit'
import { seed_path, _pgidx } from '$lib/kit_path'

export async function load({ parent }) {
  const { nvinfo, ubmemo } = await parent()
  const { sname, chidx } = ubmemo
  const location = seed_path(nvinfo.bslug, sname || '~avail', _pgidx(chidx))
  throw redirect(302, location)
}
