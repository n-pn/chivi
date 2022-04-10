<script lang="ts">
  import { dboard_ctrl as ctrl, tplist_data as data } from '$lib/stores'
  import DtpostList from '$gui/parts/cvrepl/DtpostList.svelte'
  import CvpostList from '$gui/parts/cvpost/CvpostFull.svelte'

  let cvpost: CV.Cvpost
  let tplist: CV.Tplist = {
    items: [],
    pgidx: 1,
    pgmax: 1,
  }

  $: if ($ctrl.actived && $data.topic) load_cvpost($data.topic.id)
  $: if (cvpost) load_tposts(cvpost, $data.query)

  async function load_cvpost(topic_id: string) {
    const api_url = `/api/topics/${topic_id}`
    const api_res = await fetch(api_url)
    const payload = await api_res.json()
    cvpost = payload.props.cvpost
  }

  async function load_tposts(topic: CV.Cvpost, { pg, op }) {
    let api_url = `/api/tposts?pg=${pg}&lm=20`
    if (topic) api_url += '&cvpost=' + topic.id
    if (op) api_url += '&uname=' + op

    const res = await fetch(api_url)
    const data = await res.json()

    if (res.ok) tplist = data.props.tplist
    else alert(data.error)
  }
</script>

{#if cvpost}
  <section class="topic">
    <CvpostList {cvpost} />
  </section>
  <section class="posts">
    <DtpostList {tplist} {cvpost} />
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
