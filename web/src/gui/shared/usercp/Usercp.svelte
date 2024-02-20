<script context="module" lang="ts">
  import { writable } from 'svelte/store'
  import { browser } from '$app/environment'
  import { get_dmy } from '$utils/time_utils'

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

  async function load_rdmemos(): Promise<Array<CV.Rdmemo & CV.Tsrepo>> {
    const res = await fetch(`/_rd/rdmemos?rtype=rdlog&lm=10`)
    if (!res.ok) return []
    const { items } = await res.json()
    return items
  }
</script>

<script lang="ts">
  import { get_user, popups } from '$lib/stores'
  const _user = get_user()

  import SIcon from '$gui/atoms/SIcon.svelte'
  import Slider from '$gui/molds/Slider.svelte'
  import Notifs from './Notifs.svelte'
  import RdchapList from '$gui/parts/rdmemo/RdchapList.svelte'

  export let actived = true

  $: if (actived) reload_data()

  const reload_data = async () => {
    const cv_res = await fetch('/_db/_self')
    if (cv_res.ok) $_user = await cv_res.json()
  }

  $: privi = $_user.privi || -1

  async function logout() {
    const res = await fetch('/_db/_user/logout', { method: 'DELETE' })
    if (!res.ok) return
    window.location.reload()
  }

  let show_notifs = false
</script>

<Slider class="usercp" bind:actived --slider-width="26rem">
  <svelte:fragment slot="header-left">
    <span class="-icon"><SIcon name="privi-{privi}" iset="icons" /></span>
    <span class="-text cv-user" data-privi={privi}>{$_user.uname}</span>
  </svelte:fragment>

  <svelte:fragment slot="header-right">
    <button
      class="-btn"
      on:click={() => popups.show('config')}
      data-tip="Cài đặt"
      data-tip-loc="bottom">
      <SIcon name="adjustments" />
    </button>

    <button
      class="-btn"
      class:_hl={$_user.unread_notif > 0}
      on:click={() => (show_notifs = true)}
      data-tip="Thông báo"
      data-tip-loc="bottom">
      <SIcon name="bell" />
      {#if $_user.unread_notif > 0}{$_user.unread_notif}{/if}
    </button>

    <button class="-btn" on:click={logout} data-tip="Đăng xuất" data-tip-loc="bottom">
      <SIcon name="logout" />
    </button>
  </svelte:fragment>

  <section class="body">
    <section class="infos">
      <div class="info">
        <div>
          <span class="lbl">Quyền hạn:</span>
          <SIcon name="privi-{privi}" iset="icons" />
        </div>
        {#if privi > 4}
          <a class="m-btn _xs _harmful" href="/su" target="_blank">
            <span>Quản lý</span>
          </a>
        {:else if privi < 1}
          <a class="m-btn _xs _primary" href="/me/privi">
            <span>Nâng cấp</span>
          </a>
        {:else}
          <div>
            <span class="lbl">Hết hạn:</span>
            <strong>{avail_until($_user.until)}</strong>
          </div>

          <a class="m-btn _xs _primary" href="/me/privi">
            <span>Gia hạn</span>
          </a>
        {/if}
      </div>

      <div class="info">
        <div>
          <span class="lbl">Số Vcoin:</span>
          <strong>{Math.round($_user.vcoin * 1000) / 1000}</strong>
          <SIcon iset="icons" name="vcoin" />
        </div>

        <a href="/me/vcoin" class="m-btn _xs _warning" target="_blank">
          <span>Trao đổi</span>
        </a>
      </div>

      <div class="info">
        <div>
          <span class="lbl">Quota còn thừa:</span>
          <strong>{$_user.quota}</strong>
        </div>

        <a href="/me/quota" class="m-btn _xs _primary" target="_blank">
          <span>{$_user.quota > 0 ? 'Chi tiết' : 'Gia tăng'}</span>
        </a>
      </div>
    </section>

    <hr />

    <section class="links">
      <a class="m-btn _xs" href="/me">
        <SIcon name="user" />
        <span>Cá nhân</span>
      </a>

      <a class="m-btn _xs _primary" href="/ts/track">
        <SIcon name="books" />
        <span>Đang đọc</span>
      </a>

      <a class="m-btn _xs _warning" href="/me/earned">
        <SIcon name="coin" />
        <span class="-txt">Thu phí</span>
      </a>
    </section>

    <hr />
    <h4>
      <SIcon name="history" />
      <span>Chương tiết vừa đọc</span>
      <a href="/ts/rdlog"><em>Xem tất cả</em></a>
    </h4>

    <div class="chaps">
      {#await load_rdmemos()}
        <div class="d-empty-sm">Đang tải lịch sử đọc truyện.</div>
      {:then items}
        <RdchapList {items} aside={true} />
      {/await}
    </div>
  </section>
</Slider>

{#if show_notifs}<Notifs bind:actived={show_notifs} {_user} />{/if}

<style lang="scss">
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

  hr {
    display: block;
    margin-top: 0.5rem;
    margin-bottom: 0.5rem;
    @include border(--bd-soft, $loc: top);
  }

  h4 {
    @include flex-ca($gap: 0.25rem);

    font-weight: 500;
    margin-bottom: 0.5rem;
    @include fgcolor(tert);

    > a {
      margin-left: auto;
      color: inherit;
      font-size: smaller;
      font-weight: 400;
      &:hover {
        @include fgcolor(primary, 4);
      }
    }
  }

  .links {
    @include flex-ca($gap: 0.5rem);

    // flex-direction: column;
    .m-btn {
      border-radius: 1rem;
      padding: 0 0.5rem;
    }
  }

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

  .body {
    padding: 0.5rem 0.75rem;
  }
</style>
