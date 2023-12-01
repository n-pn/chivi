<script lang="ts">
  import { page } from '$app/stores'

  import type { LayoutData } from './$types'
  import { seed_path } from '$lib/kit_path'

  import SIcon from '$gui/atoms/SIcon.svelte'

  export let data: LayoutData

  $: ({ nvinfo, wstem } = data)
  $: pg_no = +$page.url.searchParams.get('pg') || 1

  $: ({ wstems = [], ustems = [], rstems = [] } = data.bstems)
  const find_stem = (wstems: CV.Chstem[], sname: string) => {
    return wstems.find((x) => x.sname == sname) || { sname, chmax: 0 }
  }

  $: avail_stem = find_stem(wstems, '~avail')

  let show_up = false
  let show_rm = false
</script>

<div class="seed-list">
  <a
    href={seed_path(nvinfo.bslug, '~avail', pg_no)}
    class="seed-name"
    class:_active={'~avail' == wstem.sname}
    data-tip-loc="bottom">
    <div class="seed-label">Nguồn tổng hợp</div>
    <div class="seed-stats">
      <strong>{avail_stem.chmax}</strong> chương
    </div>
  </a>

  <button
    class="seed-name"
    on:click={() => (show_up = !show_up)}
    class:_active={show_up}
    data-tip="Sưu tầm cá nhân liên kết với bộ truyện"
    data-tip-loc="bottom">
    <div class="seed-label">Sưu tầm riêng</div>

    <div class="seed-stats">
      <strong>{ustems.length}+</strong> nguồn
    </div>
  </button>

  <button
    class="seed-name"
    on:click={() => (show_rm = !show_rm)}
    class:_active={show_rm}
    data-tip="Các nguồn ngoài liên kết với bộ truyện"
    data-tip-loc="bottom">
    <div class="seed-label">Liên kết ngoài</div>

    <div class="seed-stats">
      <strong>{rstems.length}+</strong> nguồn
    </div>
  </button>
</div>

{#if show_up}
  <h4 class="title">Sưu tầm cá nhân:</h4>
  <div class="seed-list _extra">
    {#each ustems as { sname, sn_id, chmax }}
      <a
        href="/up/{sname}:{sn_id}"
        class="seed-name _sub"
        data-tip="Danh sách chương cá nhân của {sname}"
        data-tip-loc="bottom">
        <div class="seed-label">{sname}</div>
        <div class="seed-stats"><strong>{chmax}</strong> chương</div>
      </a>
    {/each}

    <a
      href="/up/+proj?wn={nvinfo.id}"
      class="seed-name _sub _btn"
      data-tip="Tạo dự án cá nhân mới liên kết tới bộ truyện"
      data-tip-loc="bottom">
      <SIcon name="file-plus" />
      <div class="btn-label">Tạo mới</div>
    </a>
  </div>
{/if}

{#if show_rm}
  <h4 class="title">Nguồn liên kết ngoài:</h4>
  <div class="seed-list _extra">
    {#each rstems as { sname, sn_id, chmax }}
      <a
        href="/rm/{sname}:{sn_id}"
        class="seed-name _sub"
        class:_active={sname == wstem.sname}>
        <div class="seed-label">{sname}</div>
        <div class="seed-stats"><strong>{chmax}</strong> chương</div>
      </a>
    {/each}

    <a
      href="/rm/+stem?wn={nvinfo.id}"
      class="seed-name _sub _btn"
      data-tip="Thêm liên kết tới nguồn ngoài"
      data-tip-loc="bottom">
      <SIcon name="square-plus" />
      <span class="btn-label">Thêm mới</span>
    </a>
  </div>
{/if}

<style lang="scss">
  .seed-list {
    @include flex-cx($gap: 0.25rem);
    flex-wrap: wrap;
    padding: 0 var(--gutter);

    margin-top: 0.5rem;
    margin-left: auto;
    margin-right: auto;
    max-width: 35rem;

    &:last-of-type {
      margin-bottom: 0.5rem;
    }

    &._extra {
      margin-top: 0;
    }
  }

  @mixin label {
    font-weight: 500;
    text-transform: uppercase;
    @include fgcolor(tert);
  }

  .seed-name {
    display: flex;
    align-items: center;
    flex-direction: column;
    background-color: transparent;
    padding: 0.375rem;

    @include bdradi();
    @include linesd(--bd-main);

    // &._btn {
    // }

    &._active {
      @include linesd(primary, 5, $ndef: true);
    }

    // prettier-ignore
    &._active, &:hover, &:active {
      .seed-label { @include fgcolor(primary, 5); }
    }

    &._sub {
      padding: 0.25rem 0.375rem;
    }

    &._btn {
      @include label();
      @include fgcolor(success, 5);
      flex-direction: row;
    }
  }

  .seed-label {
    @include flex($center: both);
    @include label();

    line-height: 1rem;
    @include bps(font-size, rem(12px), $ts: rem(13px));

    ._sub > & {
      line-height: 0.875rem;
      @include bps(font-size, rem(11px), $ts: rem(12px));
    }

    > :global(svg) {
      width: 0.875rem;
      height: 0.875rem;
    }

    // > span {
    //   margin-right: 0.125em;
    // }
  }

  .btn-label {
    @include bps(font-size, rem(11px), $ts: rem(12px));
  }

  .seed-stats {
    display: block;
    text-align: center;
    line-height: 0.875rem;

    @include fgcolor(tert);
    @include bps(font-size, rem(11px), $ts: rem(12px));

    ._sub > & {
      line-height: 1rem;
      line-height: 0.75rem;
      @include bps(font-size, rem(10px), $ts: rem(11px));
    }
  }

  .title {
    @include fgcolor(tert);
    @include ftsize(sm);
    font-style: italic;
    text-align: center;
  }

  // .seed-task {
  //   display: flex;
  //   flex-wrap: wrap;
  //   justify-content: center;
  //   gap: 0.25rem;
  //   // text-align: center;
  //   margin-top: 0.5rem;
  //   margin-bottom: 0.5rem;
  // }
</style>
