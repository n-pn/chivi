<script lang="ts">
  import { dboard_ctrl as ctrl, tplist_data as data } from '$lib/stores'
  import DtpostList from '$gui/parts/dtpost/DtpostList.svelte'
  import DtopicFull from '$gui/parts/dtopic/DtopicFull.svelte'

  let dtopic: CV.Dtopic
  let tplist: CV.Tplist = {
    items: [],
    pgidx: 1,
    pgmax: 1,
  }

  $: if ($ctrl.actived && $data.topic) load_dtopic($data.topic.id)
  $: if (dtopic) load_tposts(dtopic, $data.query)

  async function load_dtopic(topic_id: string) {
    const api_url = `/api/topics/${topic_id}`
    const api_res = await fetch(api_url)
    const payload = await api_res.json()
    dtopic = payload.props.dtopic
  }

  async function load_tposts(topic: CV.Dtopic, { pg, op }) {
    let api_url = `/api/tposts?pg=${pg}&lm=20`
    if (topic) api_url += '&dtopic=' + topic.id
    if (op) api_url += '&uname=' + op

    const res = await fetch(api_url)
    const data = await res.json()

    if (res.ok) tplist = data.props.tplist
    else alert(data.error)
  }
</script>

{#if dtopic}
  <section class="topic">
    <DtopicFull {dtopic} />
  </section>
  <section class="posts">
    <DtpostList {tplist} {dtopic} />
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
