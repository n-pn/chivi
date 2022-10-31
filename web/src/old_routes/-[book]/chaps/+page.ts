import { redirect } from '@sveltejs/kit';
import { seed_url, to_pgidx } from '$utils/route_utils'

throw new Error("@migration task: Migrate the load function input (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292693)");
export async function load({ stuff }) {
  const { nvinfo, ubmemo } = stuff
  const { sname, chidx } = ubmemo
  const redirect = seed_url(nvinfo.bslug, sname || '=base', to_pgidx(chidx))
  throw redirect(303, redirect);
}
