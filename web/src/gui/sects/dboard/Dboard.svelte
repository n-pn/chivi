<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'
  import Slider from '$gui/molds/Slider.svelte'

  import { dboard_ctrl as ctrl } from '$lib/stores'

  import DtopicList from '$gui/parts/dtopic/DtopicList.svelte'
  import Dtlist from './Dtlist.svelte'
  import Tplist from './Tplist.svelte'
  import UInbox from './UInbox.svelte'

  const tabs = [
    { icon: 'home', btip: 'Tất cả chủ đề' },
    { icon: 'book', btip: 'Chủ đề của bộ truyện' },
    { icon: 'message', btip: 'Chủ đề vừa xem' },
    { icon: 'message-circle', btip: 'Phản hồi' },
  ]

  async function load_topics(dboard_id?: number) {
    let api_url = `/api/topics?pg=1&lm=10`
    if (dboard_id) api_url += '&dboard=' + dboard_id

    const res = await fetch(api_url)
    const data = await res.json()
    console.log(data)

    if (res.ok) dtlist = data.props.dtlist
    else alert(data.error)
  }

  let dboard: CV.Dboard = { id: -1, bname: 'Đại sảnh', bslug: 'dai-sanh' }

  let dtlist: CV.Dtlist = {
    items: [],
    pgidx: 1,
    pgmax: 1,
  }

  $: if ($ctrl.actived) reload_data($ctrl.tab)

  async function reload_data(tab: number) {
    switch (tab) {
      case 0:
        return await load_topics()
    }
  }
</script>

<Slider class="dboard" bind:actived={$ctrl.actived}>
  <svelte:fragment slot="header-left">
    <div class="-icon">
      <SIcon name="messages" />
    </div>
    <div class="-text">Thảo luận</div>
  </svelte:fragment>

  <svelte:fragment slot="header-right">
    {#each tabs as { icon, btip }, tab}
      <button
        class="-btn"
        class:_active={$ctrl.tab == tab}
        on:click={() => ctrl.change_tab(tab)}
        data-tip={btip}
        tip-loc="bottom">
        <SIcon name={icon} />
      </button>
    {/each}
  </svelte:fragment>

  <dboard-body>
    {#if $ctrl.tab == 0}
      <DtopicList {dboard} {dtlist} _mode={1} />
    {:else if $ctrl.tab == 1}
      <UInbox />
    {/if}
  </dboard-body>
</Slider>

<style lang="scss">
  .-btn._active {
    // @include bgcolor(primary, 1, 5);
    @include fgcolor(primary, 5);
  }

  dboard-body {
    display: block;
    padding: 0.75rem;
  }
</style>
