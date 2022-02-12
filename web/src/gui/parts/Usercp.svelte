<script lang="ts">
  import { session } from '$app/stores'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import Gslide from '$gui/molds/Gslide.svelte'

  // import Config from './Usercp/Config.svelte'
  import Replied from './Usercp/Replied.svelte'
  import Reading from './Usercp/Reading.svelte'
  import Setting from './Usercp/Setting.svelte'

  export let actived = false
  export let tab = 'replied'

  function format_coin(vcoin) {
    return vcoin < 1000 ? vcoin : vcoin / 1000 + 'K'
  }
</script>

<Gslide _klass="usercp" bind:actived _rwidth={26}>
  <svelte:fragment slot="header-left">
    <div class="-icon"><SIcon name="user" /></div>
    <div class="-text">
      <cv-user privi={$session.privi}>{$session.uname}</cv-user>
      <span class="stats"
        ><SIcon name="crown" /><span>{$session.privi}</span></span>
      <span class="stats"
        ><SIcon name="coin" /><span>{format_coin($session.vcoin)}</span></span>
    </div>
  </svelte:fragment>

  <svelte:fragment slot="header-right">
    <button
      class="-btn"
      class:_active={tab == 'replied'}
      on:click={() => (tab = 'replied')}
      data-tip="Phản hồi"
      tip-loc="bottom">
      <SIcon name="messages" />
    </button>

    <button
      class="-btn"
      class:_active={tab == 'reading'}
      on:click={() => (tab = 'reading')}
      data-tip="Lịch sửa đọc"
      tip-loc="bottom">
      <SIcon name="history" />
    </button>

    <button
      class="-btn"
      class:_active={tab == 'setting'}
      on:click={() => (tab = 'setting')}
      data-tip="Cài đặt"
      tip-loc="bottom">
      <SIcon name="settings" />
    </button>
  </svelte:fragment>

  {#if tab == 'reading'}
    <Reading />
  {:else if tab == 'setting'}
    <Setting bind:tab />
  {:else}
    <Replied />
  {/if}
</Gslide>

<style lang="scss">
  .-btn._active {
    // @include bgcolor(primary, 1, 5);
    @include fgcolor(primary, 5);
  }

  .stats {
    margin-left: 0.25rem;
    // padding-top: 0.25rem;
    @include fgcolor(mute);
    // @include ftsize(sm);

    :global(svg) {
      width: 1.125rem;
      height: 1.125rem;
    }

    span {
      margin-left: 0.125rem;
      text-transform: none;
    }
  }
</style>
