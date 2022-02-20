<script lang="ts">
  import { session } from '$app/stores'
  import { usercp as ctrl } from '$lib/stores'
  import { get_dmy } from '$utils/time_utils'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import Gslide from '$gui/molds/Gslide.svelte'

  // import Config from './Usercp/Config.svelte'
  import Replied from './Usercp/Replied.svelte'
  import Reading from './Usercp/Reading.svelte'
  import Setting from './Usercp/Setting.svelte'
  import UVcoin from './Usercp/UVcoin.svelte'

  function format_coin(vcoin: number) {
    return vcoin < 1000 ? vcoin : vcoin / 1000 + 'K'
  }

  $: on_tab = $ctrl.tab

  const hour_span = 3600
  const day_span = 3600 * 24
  const month_span = day_span * 30

  function avail_until(privi: number) {
    const time = $session[`privi_${privi}_until`]
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

<Gslide _klass="usercp" bind:actived={$ctrl.actived} _rwidth={26}>
  <svelte:fragment slot="header-left">
    <div class="-icon"><SIcon name="user" /></div>
    <div class="-text">
      <cv-user data-privi={$session.privi}>{$session.uname}</cv-user>
    </div>
  </svelte:fragment>

  <svelte:fragment slot="header-right">
    <button
      class="-btn"
      class:_active={on_tab == 0}
      on:click={() => ctrl.change_tab(0)}
      data-tip="Phản hồi"
      tip-loc="bottom">
      <SIcon name="messages" />
    </button>
    <button
      class="-btn"
      class:_active={on_tab == 1}
      on:click={() => ctrl.change_tab(1)}
      data-tip="Lịch sửa đọc"
      tip-loc="bottom">
      <SIcon name="history" />
    </button>
    <button
      class="-btn"
      class:_active={on_tab == 2}
      on:click={() => ctrl.change_tab(2)}
      data-tip="Cài đặt"
      tip-loc="bottom">
      <SIcon name="settings" />
    </button>
    <button
      class="-btn"
      class:_active={on_tab == 3}
      on:click={() => ctrl.change_tab(3)}>
      <SIcon name="coin" />
    </button>
  </svelte:fragment>

  <section class="infos">
    <div class="info">
      <div>
        <span class="lbl">Quyền hạn:</span>
        <SIcon name="crown" /><strong>{$session.privi}</strong>
      </div>
      {#if $session.privi > 0 && $session.privi < 4}
        <div>
          <span class="lbl">Hết hạn:</span>
          <strong>{avail_until($session.privi)}</strong>
        </div>
      {/if}
      <button class="m-btn _xs _primary" on:click={() => ctrl.change_tab(2)}
        >{$session.privi < 1 ? 'Nâng cấp' : 'Gia hạn'}</button>
    </div>

    <div class="info">
      <div>
        <span class="lbl">Số lượng vcoin hiện có:</span>
        <SIcon name="coin" /><strong>{$session.vcoin_avail}</strong>
      </div>

      <button class="m-btn _xs" on:click={() => ctrl.change_tab(3)}
        >Chi tiết</button>
    </div>
  </section>

  {#if on_tab == 1}
    <Reading />
  {:else if on_tab == 2}
    <Setting bind:tab={$ctrl.tab} />
  {:else if on_tab == 3}
    <UVcoin bind:tab={$ctrl.tab} />
  {:else}
    <Replied />
  {/if}
</Gslide>

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

    > button {
      margin-left: auto;
    }

    :global(svg) {
      height: 1rem;
      width: 1rem;
      margin-bottom: 0.125rem;
      margin-right: 0.075rem;
    }
  }
</style>
