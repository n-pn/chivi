import { redirect } from '@sveltejs/kit'
import { seed_path, _pgidx } from '$lib/kit_path'

export async function load({ parent }) {
  const { nvinfo, ubmemo } = await parent()
  let { sname, chidx } = ubmemo
  if (sname.charAt(0) != '~') sname = '~avail'
  const location = seed_path(nvinfo.bslug, sname, _pgidx(chidx))
  throw redirect(302, location)
}
