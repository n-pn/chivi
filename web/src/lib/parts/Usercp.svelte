<script>
  import { session } from '$app/stores'

  import SIcon from '$atoms/SIcon.svelte'
  import Gslide from '$molds/Gslide.svelte'

  // import Config from './Usercp/Config.svelte'
  import Replied from './Usercp/Replied.svelte'
  import Reading from './Usercp/Reading.svelte'
  import Setting from './Usercp/Setting.svelte'

  export let actived = false
  export let tab = 'replied'
</script>

<Gslide _klass="usercp" bind:actived _rwidth={26}>
  <svelte:fragment slot="header-left">
    <div class="-icon"><SIcon name="user" /></div>
    <div class="-text">
      <cv-user privi={$session.privi}>{$session.uname}</cv-user>
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
    <Setting />
  {:else}
    <Replied />
  {/if}
</Gslide>

<style lang="scss">
  .-btn._active {
    // @include bgcolor(primary, 1, 5);
    @include fgcolor(primary, 5);
  }
</style>
