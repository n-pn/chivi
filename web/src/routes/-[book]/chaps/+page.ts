import { redirect } from '@sveltejs/kit'
import { seed_url, to_pgidx } from '$utils/route_utils'

export async function load({ parent }) {
  const { nvinfo, ubmemo } = await parent()
  const { sname, chidx } = ubmemo

  const location = seed_url(nvinfo.bslug, sname || '=base', to_pgidx(chidx))
  throw redirect(303, encodeURI(location))
}
