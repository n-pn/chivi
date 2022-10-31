import { nvinfo_bar } from '$utils/topbar_utils'
import { suggest_read } from '$utils/ubmemo_utils'

throw new Error("@migration task: Migrate the load function input (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292693)");
export async function load({ stuff }) {
  const { nvinfo, ubmemo } = stuff

  const topbar = {
    left: [nvinfo_bar(nvinfo)],
    right: [suggest_read(nvinfo, ubmemo)],
  }
  throw new Error("@migration task: Migrate this return statement (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292693)");
  return { props: stuff, stuff: { topbar, nv_tab: 'chaps' } }
}
