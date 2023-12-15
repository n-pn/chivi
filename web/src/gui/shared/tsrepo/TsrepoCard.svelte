<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'
  import BCover from '$gui/atoms/BCover.svelte'
  import { rstate_icons, rstate_labels } from '$lib/consts/rd_states'
  import { _pgidx } from '$lib/kit_path'

  export let crepo: CV.Tsrepo

  $: pg_no = crepo.lc_ch_no > 32 ? _pgidx(crepo.lc_ch_no) : 1
  $: query = pg_no > 1 ? `?pg=${pg_no}` : ''
  $: cover = crepo.cover || '//cdn.chivi.app/covers/blank.png'

  $: state = crepo.rd_state || 0

  const stype_colors = [1, 3, 2]

  const ratings = ['', '🤮', '🙁', '😐', '🙂', '🤩']

  const stype_icons = ['books', 'album', 'world']
</script>

<a class="crepo" href="/ts/{crepo.sroot}{query}">
  <div class="cover">
    <BCover srcset={cover} />

    <div class="badge _tl">
      <span class="label" data-tip="Loại nguồn">
        <SIcon name={stype_icons[crepo.stype]} />
        {crepo.sname.replace('.com', '')}
      </span>
      <span class="label _1" data-tip="Số chương">{crepo.chmax}</span>
    </div>

    <div class="badge _bl">
      <span class="label _{state}" data-tip="Đánh dấu nguồn">
        <SIcon name={rstate_icons[state]} />
        <span>{state > 0 ? rstate_labels[state] : 'Chưa đọc'}</span>
      </span>

      <span class="label _2" data-tip="Chương đã đọc">{crepo.lc_ch_no}</span>
    </div>

    {#if crepo.rd_stars > 0}
      <div class="badge _br">
        <span class="label _lg" data-tip="Cho điểm">
          {ratings[crepo.rd_stars]}
        </span>
      </div>
    {/if}
  </div>

  <div class="title">{crepo.vname}</div>
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
    line-height: 0.9rem;
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
      height: 0.75rem;
      width: 0.75rem;
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
</style>
