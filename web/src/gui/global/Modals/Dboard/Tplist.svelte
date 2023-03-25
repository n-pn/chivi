<script context="module" lang="ts">
  import { dboard_ctrl as ctrl, tplist_data, popups } from '$lib/stores'

  export function make_api_url(data: CV.Cvpost, { pg, op }) {
    let api_url = `/_db/tposts`
    if (data) api_url += '?post_id=' + data.id
    if (op) api_url += '&uname=' + op

    return api_url
  }
</script>

<script lang="ts">
  import { invalidate } from '$app/navigation'

  import CvpostFull from '$gui/parts/dboard/CvpostFull.svelte'
  import CvreplList from '$gui/parts/dboard/CvreplList.svelte'

  let cvpost: CV.Cvpost
  let tplist: CV.Cvrepl[] = []

  $: post_api_url = `/_db/topics/${$tplist_data.topic.id}`
  $: list_api_url = make_api_url(cvpost, $tplist_data.query)

  $: if ($popups.dboard && $tplist_data.topic) load_cvpost(post_api_url)
  $: if (cvpost) load_tposts(list_api_url)

  const on_cvpost_form = async () => {
    await invalidate(post_api_url)
    await load_cvpost(post_api_url)
  }

  const on_cvrepl_form = async () => {
    await invalidate(list_api_url)
    await load_tposts(list_api_url)
  }

  async function load_cvpost(url: string) {
    const data = await fetch(url).then((r) => r.json())
    cvpost = data.cvpost
  }

  async function load_tposts(api_url: string) {
    const res = await fetch(api_url)
    if (!res.ok) alert(await res.text())
    else tplist = (await res.json()) as CV.Cvrepl[]
  }
</script>

{#if cvpost}
  <section class="topic">
    <CvpostFull {cvpost} {on_cvpost_form} />
  </section>
  <section class="posts">
    <CvreplList {tplist} {cvpost} {on_cvrepl_form} />
  </section>
{:else}
  Chưa chọn chủ đề
{/if}

<style lang="scss">
  .topic {
    padding: 0 0.75rem;
    margin-bottom: 0.5rem;
  }

  .posts {
    padding: 0.75rem;
  }
</style>
