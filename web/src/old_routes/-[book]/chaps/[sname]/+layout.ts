throw new Error("@migration task: Migrate the load function input (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292693)");
export async function load({ stuff, params }) {
  const { api, nvinfo } = stuff

  const nvseed = await api.nvseed(nvinfo.id, params.sname)
  throw new Error("@migration task: Migrate this return statement (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292693)");
  return nvseed.error ? nvseed : { props: { nvinfo }, stuff: { nvseed } }
}
