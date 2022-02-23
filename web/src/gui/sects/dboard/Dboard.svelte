<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'
  import Slider from '$gui/molds/Slider.svelte'

  import { dboard_ctrl as ctrl } from '$lib/stores'

  import Dtlist from './Dtlist.svelte'
  import Tplist from './Tplist.svelte'
  import UInbox from './UInbox.svelte'

  const tabs = [
    { icon: 'home', btip: 'Tất cả chủ đề' },
    { icon: 'message', btip: 'Bình luận chủ đề' },
    { icon: 'mail-opened', btip: 'Phản hồi cá nhân' },
  ]
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
      <Dtlist data={$ctrl.tab_0} />
    {:else if $ctrl.tab == 1}
      <Tplist data={$ctrl.tab_1} />
    {:else if $ctrl.tab == 2}
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
