<script context="module" lang="ts">
  import { writable } from 'svelte/store'
  import { browser } from '$app/environment'

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
  import { get_user } from '$lib/stores'
  import { get_dmy } from '$utils/time_utils'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import Slider from '$gui/molds/Slider.svelte'

  import Config from './Config.svelte'
  import Reading from './Reading.svelte'
  import Spending from './Spending.svelte'
  import Setting from './Setting.svelte'
  import Notifs from './Notifs.svelte'

  const components = [Config, Reading, Notifs, Spending, Setting]

  export let actived = true
  const _user = get_user()

  $: if (actived) reload_user_data()

  const reload_user_data = async () => {
    const res = await fetch('/_db/_self')
    if (res.ok) $_user = await res.json()
  }

  const tabs = [
    { icon: 'adjustments-alt', btip: 'Giao diện' },
    { icon: 'history', btip: 'Lịch sử' },
    { icon: 'bell', btip: 'Thông báo' },
    { icon: 'wallet', btip: 'Giao dịch' },
    { icon: 'settings', btip: 'Cài đặt' },
  ]

  $: privi = $_user.privi || 0
</script>

<Slider class="usercp" bind:actived --slider-width="26rem">
  <svelte:fragment slot="header-left">
    <div class="-icon"><SIcon name="privi-{privi}" iset="icons" /></div>
    <div class="-text">
      <cv-user data-privi={privi}>{$_user.uname}</cv-user>
    </div>
  </svelte:fragment>

  <svelte:fragment slot="header-right">
    {#each tabs as { icon, btip }, tab}
      {@const _hl = tab == 2 && $_user.unread_notif > 0}
      <button
        class="-btn"
        class:_active={tab == $usercp}
        class:_hl
        on:click={() => usercp.change_tab(tab)}
        data-tip={btip}
        data-tip-loc="bottom">
        <SIcon name={icon} />
        {#if _hl}{$_user.unread_notif}{/if}
      </button>
    {/each}
  </svelte:fragment>

  {#if $usercp == 0}
    <section class="infos">
      <div class="info">
        <div>
          <span class="lbl">Quyền hạn:</span>
          <SIcon name="privi-{privi}" iset="icons" />
        </div>
        {#if privi > 0 && privi < 4}
          <div>
            <span class="lbl">Hết hạn:</span>
            <strong>{avail_until($_user.until)}</strong>
          </div>
        {/if}
        <button class="m-btn _xs _primary" on:click={() => usercp.change_tab(3)}
          >{privi < 1 ? 'Nâng cấp' : 'Gia hạn'}</button>
      </div>

      <div class="info">
        <div>
          <span class="lbl">Số lượng vcoin hiện có:</span>
          <strong>{Math.round($_user.vcoin * 1000) / 1000}</strong>
          <SIcon iset="icons" name="vcoin" />
        </div>

        <a href="/hd/tat-ca-ve-vcoin" class="m-btn _xs">Giải thích</a>
      </div>
    </section>
  {/if}

  <section class="body">
    {#if actived && browser}
      <svelte:component this={components[$usercp]} {_user} />
    {/if}
  </section>
</Slider>

<style lang="scss">
  // .-btn._dot:after {
  //   $size: 0.625rem;
  //   position: absolute;

  //   content: '';
  //   right: math.div($size * -1, 3);
  //   top: math.div($size * -1, 3);
  //   width: $size;
  //   height: $size;
  //   border-radius: $size;
  //   @include bgcolor(warning, 5);
  // }

  .-btn._hl {
    @include fgcolor(warning, 5);
  }

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

  .body {
    padding: 0.75rem;
  }
</style>