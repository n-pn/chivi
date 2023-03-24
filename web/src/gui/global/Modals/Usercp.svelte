<script context="module" lang="ts">
  import { writable } from 'svelte/store'

  export const usercp = {
    ...writable(0),
    change_tab: (tab: number) => usercp.set(tab),
  }

  const hour_span = 3600
  const day_span = 3600 * 24
  const month_span = day_span * 30

  function avail_until(time: number) {
    const diff = time - new Date().getTime() / 1000

    if (diff < hour_span) return '< 1 tiếng'
    if (diff < day_span) return `${round(diff, hour_span)} tiếng`
    if (diff < month_span) return `${round(diff, day_span)} ngày`

    return get_dmy(new Date(time * 1000))
  }

  function round(input: number, unit: number) {
    return input <= unit ? 1 : Math.floor(input / unit)
  }
</script>

<script lang="ts">
  import { page } from '$app/stores'
  import { get_dmy } from '$utils/time_utils'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import Slider from '$gui/molds/Slider.svelte'

  import Reading from './Usercp/Reading.svelte'
  import Setting from './Usercp/Setting.svelte'

  const components = [Reading, Setting]

  export let actived = false
  let user = $page.data._user

  $: if (actived) reload()

  const reload = async () => {
    user = await fetch('/_db/_self').then((r) => r.json())
  }

  const tabs = [
    { icon: 'history', btip: 'Lịch sửa đọc' },
    { icon: 'settings', btip: 'Cài đặt' },
  ]

  $: privi = user.privi || 0
</script>

<Slider class="usercp" bind:actived --slider-width="26rem">
  <svelte:fragment slot="header-left">
    <div class="-icon"><SIcon name="privi-{privi}" iset="sprite" /></div>
    <div class="-text">
      <cv-user data-privi={privi}>{user.uname}</cv-user>
    </div>
  </svelte:fragment>

  <svelte:fragment slot="header-right">
    {#each tabs as { icon, btip }, tab}
      <button
        class="-btn"
        class:_active={tab == $usercp}
        on:click={() => usercp.change_tab(tab)}
        data-tip={btip}
        data-tip-loc="bottom">
        <SIcon name={icon} />
      </button>
    {/each}
  </svelte:fragment>

  <section class="infos">
    <div class="info">
      <div>
        <span class="lbl">Quyền hạn:</span>
        <SIcon name="privi-{privi}" iset="sprite" />
      </div>
      {#if privi > 0 && privi < 4}
        <div>
          <span class="lbl">Hết hạn:</span>
          <strong>{avail_until(user.until)}</strong>
        </div>
      {/if}
      <button class="m-btn _xs _primary" on:click={() => usercp.change_tab(1)}
        >{privi < 1 ? 'Nâng cấp' : 'Gia hạn'}</button>
    </div>

    <div class="info">
      <div>
        <span class="lbl">Số lượng vcoin hiện có:</span>
        <SIcon name="coin" /><strong
          >{Math.round(user.vcoin * 100) / 100}</strong>
      </div>

      <a href="/hd/vcoin" class="m-btn _xs">Giải thích</a>
    </div>
  </section>

  <usercp-body>
    {#if actived}
      <svelte:component
        this={components[$usercp]}
        bind:tab={$usercp}
        bind:user />
    {/if}
  </usercp-body>
</Slider>

<style lang="scss">
  .-btn._active {
    // @include bgcolor(primary, 1, 5);
    @include fgcolor(primary, 5);
  }

  .infos {
    // padding: 0.75rem;
    margin: 0 0.75rem;
    padding: 0.5rem 0;
    @include border($loc: bottom);
  }

  .info {
    @include flex-cy;

    & + & {
      margin-top: 0.25rem;
    }

    > div {
      margin-right: 0.5rem;
      @include ftsize(sm);
      @include fgcolor(secd);
    }

    .lbl {
      @include fgcolor(tert);
    }

    > button,
    a {
      margin-left: auto;
    }

    :global(svg) {
      height: 1rem;
      width: 1rem;
      margin-bottom: 0.125rem;
      margin-right: 0.075rem;
    }
  }

  usercp-body {
    display: block;
    padding: 0.75rem;
  }
</style>
