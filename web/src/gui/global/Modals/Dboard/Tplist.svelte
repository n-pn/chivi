<script context="module" lang="ts">
  import { dboard_ctrl, tplist_data, popups } from '$lib/stores'

  export function make_api_url(data: CV.Dtopic, { op }) {
    let api_url = `/_db/mrepls`
    if (data) api_url += `/thread/gd:${data.id || 0}`
    if (op) api_url += '?from=' + op

    return api_url
  }
</script>

<script lang="ts">
  import { invalidate } from '$app/navigation'

  import DtopicFull from '$gui/parts/dboard/DtopicFull.svelte'
  import RpnodeList from '$gui/parts/dboard/RpnodeList.svelte'

  let cvpost: CV.DtopicFull = {
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
  $: if (cvpost) load_repls(list_api_url)

  $: thread = {
    to: cvpost.post.user_id,
    id: cvpost.post.id,
    mu: 0,
  }

  const on_cvpost_form = async () => {
    await invalidate(post_api_url)
    await load_cvpost(post_api_url)
  }

  const on_rpnode_form = async () => {
    await invalidate(list_api_url)
    await load_repls(list_api_url)
  }

  async function load_cvpost(url: string) {
    cvpost = await fetch(url).then((r) => r.json())
  }

  async function load_repls(api_url: string) {
    const res = await fetch(api_url)
    if (!res.ok) alert(await res.text())
    else rplist = await res.json()
  }
</script>

{#if cvpost}
  <section class="topic">
    <DtopicFull {...cvpost} {on_cvpost_form} />
  </section>
  <section class="posts">
    <RpnodeList {thread} {rplist} {on_rpnode_form} />
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
