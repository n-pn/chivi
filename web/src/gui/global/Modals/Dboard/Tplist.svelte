<script context="module" lang="ts">
  import { dboard_ctrl, tplist_data, popups } from '$lib/stores'

  export function make_api_url(data: CV.Cvpost, { op }) {
    let api_url = `/_db/tposts`
    if (data) api_url += '?post=' + data.id
    if (op) api_url += '&uname=' + op

    return api_url
  }
</script>

<script lang="ts">
  import { invalidate } from '$app/navigation'

  import CvpostFull from '$gui/parts/dboard/CvpostFull.svelte'
  import CvreplList from '$gui/parts/dboard/CvreplList.svelte'

  let cvpost: CV.CvpostFull = {
    post: { dboard: { id: 0, bname: '', bslug: '' }, bhtml: '', labels: [] },
    user: {},
    memo: {},
  }

  let rplist: CV.Rplist = {
    repls: [],
    users: {},
    memos: {},
    pgidx: 0,
    pgmax: 0,
  }

  $: post_api_url = `/_db/topics/${$tplist_data.topic.id}`
  $: list_api_url = make_api_url(cvpost.post, $tplist_data.query)

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
    cvpost = await fetch(url).then((r) => r.json())
  }

  async function load_tposts(api_url: string) {
    const res = await fetch(api_url)
    if (!res.ok) alert(await res.text())
    else rplist = await res.json()

    console.log(rplist)
  }
</script>

{#if cvpost}
  <section class="topic">
    <CvpostFull {...cvpost} {on_cvpost_form} />
  </section>
  <section class="posts">
    <CvreplList {rplist} cvpost={cvpost.post} {on_cvrepl_form} />
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
