<script lang="ts">
  import { dboard_ctrl as ctrl, TplistData } from '$lib/stores'
  import DtpostList from '$gui/parts/dtpost/DtpostList.svelte'

  export let data = new TplistData()

  let tplist: CV.Tplist = {
    items: [],
    pgidx: 1,
    pgmax: 1,
  }

  $: if ($ctrl.actived) load_tposts(data)

  async function load_tposts({ t0 = null, pg = 1, op = null }) {
    let api_url = `/api/tposts?pg=${pg}&lm=20`
    if (t0) api_url += '&dtopic=' + t0.id
    if (op) api_url += '&uname=' + op

    const res = await fetch(api_url)
    const data = await res.json()

    if (res.ok) tplist = data.props.tplist
    else alert(data.error)
  }
</script>

{#if data.t0}
  <DtpostList {tplist} dtopic={data.t0} />
{:else}
  Chưa chọn chủ đề
{/if}
