<script lang="ts">
  import { page } from '$app/stores'
  import { session } from '$lib/stores'

  import SIcon from '$gui/atoms/SIcon.svelte'

  import type { LayoutData } from './$types'
  import { book_path, seed_path } from '$lib/kit_path'
  export let data: LayoutData

  $: ({ nvinfo, seeds, curr_seed } = data)

  $: pgidx = +$page.url.searchParams.get('pg') || 1

  $: uname = '@' + $session.uname
  $: _self = seeds.users.find((x) => x.sname == uname)

  let show_bg = false
</script>

<div class="seed-list">
  <a
    href={seed_path(nvinfo.bslug, seeds._main.sname, pgidx)}
    class="seed-name"
    class:_active={seeds._main.sname == curr_seed.sname}
    data-tip="Danh sách chương trộn tổng hợp"
    data-tip-loc="bottom">
    <div class="seed-label">Tổng hợp</div>
    <div class="seed-stats"><strong>{seeds._main.chmax}</strong> chương</div>
  </a>

  {#each seeds.users as seed}
    {@const { sname, chmax } = seed}
    {#if chmax > 0 && sname != uname}
      <a
        href={seed_path(nvinfo.bslug, sname, pgidx)}
        class="seed-name"
        class:_active={sname == curr_seed.sname}
        data-tip="Danh sách chương cá nhân của {sname}"
        data-tip-loc="bottom">
        <div class="seed-label">{sname}</div>
        <div class="seed-stats"><strong>{chmax}</strong> chương</div>
      </a>
    {/if}
  {/each}

  {#if _self && $session.privi > 0}
    <a
      href={seed_path(nvinfo.bslug, _self.sname, pgidx)}
      class="seed-name"
      class:_active={_self.sname == curr_seed.sname}
      data-tip="Danh sách chương của cá nhân bạn"
      data-tip-loc="bottom">
      <div class="seed-label">Của bạn</div>
      <div class="seed-stats"><strong>{_self.chmax}</strong> chương</div>
    </a>
  {/if}

  <button
    class="seed-name _btn"
    class:_active={show_bg}
    data-tip="Các nguồn text cơ sở có thể được thừa kế bằng các nguồn khác"
    data-tip-loc="bottom"
    on:click={() => (show_bg = !show_bg)}>
    <div class="seed-label">Nguồn nền</div>
    <div class="seed-stats"><strong>{seeds.backs.length}</strong> nguồn</div>
  </button>
</div>

{#if show_bg}
  <div class="seed-list -extra">
    {#each seeds.backs as { sname, chmax }}
      <a
        href={seed_path(nvinfo.bslug, sname, pgidx)}
        class="seed-name _sub"
        class:_active={sname == curr_seed.sname}>
        <div class="seed-label">{sname}</div>
        <div class="seed-stats"><strong>{chmax}</strong> chương</div>
      </a>
    {/each}

    <a
      href={book_path(nvinfo.bslug, 'chaps/+seed')}
      class="seed-name _sub _btn"
      class:_disable={$session.privi < 2}
      data-tip="Thêm/sửa/xóa các nguồn ngoài">
      <SIcon name="tools" />
      <span class="label">Quản lý</span>
    </a>
  </div>
{/if}

<style lang="scss">
  .seed-list {
    @include flex-cx($gap: 0.25rem);
    flex-wrap: wrap;
    padding: 0 var(--gutter);

    margin-top: 0.5rem;

    &:last-of-type {
      margin-bottom: 0.5rem;
    }
  }

  @mixin label {
    font-weight: 500;
    text-transform: uppercase;
    @include fgcolor(tert);
  }

  .seed-name {
    display: inline-block;
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

  .label {
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
