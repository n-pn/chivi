<script lang="ts">
  import { page } from '$app/stores'

  import type { LayoutData } from './$types'
  import { seed_path } from '$lib/kit_path'
  export let data: LayoutData

  $: ({ nvinfo, seed_list, curr_seed } = data)

  $: pg_no = +$page.url.searchParams.get('pg') || 1
</script>

<div class="seed-list">
  <a
    href={seed_path(nvinfo.bslug, '~avail', pg_no)}
    class="seed-name"
    class:_active={'~avail' == curr_seed.sname}
    data-tip-loc="bottom">
    <div class="seed-label">Tổng hợp</div>
    <div class="seed-stats">
      <strong>{seed_list.avail.chmax}</strong> chương
    </div>
  </a>

  <a
    href={seed_path(nvinfo.bslug, seed_list.draft.sname, pg_no)}
    class="seed-name"
    class:_active={seed_list.draft.sname == curr_seed.sname}
    data-tip="Danh sách chương tạm thời"
    data-tip-loc="bottom">
    <div class="seed-label">Tạm thời</div>
    <div class="seed-stats">
      <strong>{seed_list.draft.chmax}</strong> chương
    </div>
  </a>

  <a
    href={seed_path(nvinfo.bslug, '~chivi', pg_no)}
    class="seed-name"
    class:_active={seed_list.chivi.sname == curr_seed.sname}
    data-tip="Danh sách chương chính thức"
    data-tip-loc="bottom">
    <div class="seed-label">Chính thức</div>
    <div class="seed-stats">
      <strong>{seed_list.chivi.chmax}</strong> chương
    </div>
  </a>
</div>

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
