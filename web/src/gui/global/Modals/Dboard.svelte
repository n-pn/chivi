<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'
  import Slider from '$gui/molds/Slider.svelte'

  import Dtlist from './Dboard/Dtlist.svelte'
  import Tplist from './Dboard/Tplist.svelte'
  import UInbox from './Dboard/UInbox.svelte'

  import { dboard_ctrl as ctrl } from '$lib/stores'

  export let actived = false

  const tabs = [
    ['messages', 'Chủ đề thảo luận'],
    ['message', 'Bình luận chủ đề'],
    ['mail-opened', 'Phản hồi cá nhân'],
  ]

  $: [curr_icon, curr_text] = tabs[$ctrl.tab]
</script>

<Slider class="dboard" bind:actived --slider-width="32rem">
  <svelte:fragment slot="header-left">
    <div class="-icon"><SIcon name={curr_icon} /></div>
    <div class="-text">{curr_text}</div>
  </svelte:fragment>

  <svelte:fragment slot="header-right">
    {#each tabs as [icon, btip], tab}
      <button
        class="-btn"
        class:_active={$ctrl.tab == tab}
        on:click={() => ctrl.change_tab(tab)}
        data-tip={btip}
        data-tip-loc="bottom">
        <SIcon name={icon} />
      </button>
    {/each}
  </svelte:fragment>

  {#if actived}
    <dboard-body>
      {#if $ctrl.tab == 0}
        <Dtlist />
      {:else if $ctrl.tab == 1}
        <Tplist />
      {:else if $ctrl.tab == 2}
        <UInbox />
      {/if}
    </dboard-body>
  {/if}
</Slider>

<style lang="scss">
  .-btn._active {
    // @include bgcolor(primary, 1, 5);
    @include fgcolor(primary, 5);
  }

  dboard-body {
    display: flex;
    flex-direction: column;
    height: 100%;
    padding-top: 0.5rem;
  }
</style>
