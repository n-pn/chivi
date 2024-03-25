<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'
  import BCover from '$gui/atoms/BCover.svelte'
  import { _pgidx } from '$lib/kit_path'

  export let crepo: CV.Tsrepo
  export let rmemo: Partial<CV.Rdmemo> = { lc_ch_no: 0, rd_state: 0, rd_stars: 0 }

  $: pg_no = rmemo.lc_ch_no > 32 ? _pgidx(rmemo.lc_ch_no) : 1
  $: query = pg_no > 1 ? `?pg=${pg_no}` : ''
  $: cover = crepo.cover || '//img.chivi.app/covers/blank.png'

  const ratings = ['', '🤮', '🙁', '😐', '🙂', '🤩']
  const stype_icons = ['books', 'album', 'world']

  const rstate_types = ['Chưa đánh dấu', 'Đang đọc', 'Hoàn thành', 'Tạm dừng', 'Vứt bỏ', 'Đọc sau']
  const rstate_icons = ['eye', 'eyeglass', 'square-check', 'player-pause', 'trash', 'calendar']
</script>

<a class="crepo" href="/ts/{crepo.sroot}{query}">
  <div class="cover">
    <BCover srcset={cover} />

    {#if rmemo.lc_ch_no > 0 || rmemo.rd_state > 0}
      <div
        class="badge _tr label _{rmemo.rd_state}"
        data-tip="{rstate_types[rmemo.rd_state]} / Đã đọc / Tổng chương">
        <SIcon name={rstate_icons[rmemo.rd_state]} />
        <span>{rmemo.lc_ch_no}</span>
        <span>/</span>
        <span>{crepo.chmax}</span>
        {#if rmemo.rd_stars > 0}{ratings[rmemo.rd_stars]}{/if}
      </div>
    {/if}
  </div>

  <div class="title">{crepo.vname}</div>
  <div class="sname m-flex _cy">
    <SIcon name={stype_icons[crepo.stype]} />
    <span>{crepo.sname}</span>
  </div>
</a>

<style lang="scss">
  .crepo:nth-child(25) {
    @include bps(display, none, $tm: block, $ls: none);
  }

  .cover {
    position: relative;

    &:before {
      position: absolute;
      top: 0;
      left: 0;
      bottom: 0;
      right: 0;
      z-index: 1;
      content: '';

      background: linear-gradient(
        to bottom,
        rgba(0, 0, 0, 0.5),
        transparent 20%,
        transparent 80%,
        rgba(0, 0, 0, 0.5)
      );
    }
  }

  .badge {
    @include flex-ca;
    position: absolute;
    z-index: 2;

    font-weight: 500;
    line-height: 1rem;
    border-radius: 4px;
    height: 1.25rem;
    @include shadow;

    &._tl {
      top: 0.5rem;
      left: 0.5rem;
    }

    &._tr {
      top: 0.5rem;
      right: 0.5rem;
    }

    &._bl {
      bottom: 0.5rem;
      left: 0.5rem;
    }

    &._br {
      bottom: 0.5rem;
      right: 0.5rem;
    }

    > :first-child {
      @include bdradi(4px, $loc: left);
    }

    > :last-child {
      @include bdradi(4px, $loc: right);
    }

    :global(svg) {
      height: 0.875rem;
      width: 0.875rem;
      // margin-top: -0.15em;
    }
  }

  .label {
    padding: 0.25rem;
    @include ftsize(xs);

    @include flex-ca($gap: 0.125rem);
    @include fgcolor(white);
    @include bgcolor(neutral, 6, 7);

    &._1 {
      @include bgcolor(primary, 6, 8);
    }

    &._2 {
      @include bgcolor(success, 6, 8);
    }

    &._3 {
      @include bgcolor(warning, 6, 8);
    }

    &._4 {
      @include bgcolor(harmful, 6, 8);
    }

    &._5 {
      @include bgcolor(private, 6, 8);
    }

    &._lg {
      @include ftsize(sm);
    }
  }

  .title {
    display: -webkit-box;
    -webkit-box-orient: vertical;
    -webkit-line-clamp: 2;
    overflow: hidden;

    margin-top: 0.375rem;
    line-height: 1.125rem;
    font-size: rem(15px);
    font-weight: 500;
    @include fgcolor(neutral, 7);

    @include tm-dark {
      @include fgcolor(neutral, 3);
    }
  }

  .sname {
    font-weight: 500;
    font-size: rem(11px);
    text-transform: uppercase;
    line-height: 1rem;
    margin-top: 0.125rem;
    @include fgcolor(neutral, 5);
  }
</style>
