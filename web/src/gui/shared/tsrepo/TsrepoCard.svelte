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
</script>

<a class="crepo" href="/ts/{crepo.sroot}{query}">
  <div class="cover">
    <BCover srcset={cover} />

    <div class="stype _{stype_colors[crepo.stype]}" data-tip="Loại nguồn">
      {crepo.sname.replace('.com', '')}
    </div>

    {#if crepo.rd_stars > 0}
      <div class="stars" data-tip="Cho điểm">
        {ratings[crepo.rd_stars]}
      </div>
    {/if}

    {#if state > 0}
      <div class="rstate _{state}" data-tip={rstate_labels[state]}>
        <SIcon name={rstate_icons[state]} />
      </div>
    {/if}

    <div class="stats">
      <div class="chmax" data-tip="Tổng số chương">{crepo.chmax}</div>
      <div class="rdlog _2" data-tip="Chương đã đọc">{crepo.lc_ch_no}</div>
    </div>
  </div>
  <div class="title">{crepo.vname}</div>
</a>

<style lang="scss">
  .crepo:nth-child(25) {
    @include bps(display, none, $tm: block, $ls: none);
  }

  .cover {
    position: relative;
  }

  @mixin badge {
    font-weight: 500;
    line-height: 0.9rem;
    padding: 0.25rem;

    border-radius: 4px;

    @include ftsize(xs);
    @include fgcolor(white);

    @include bgcolor(neutral, 6, 8);
    @include shadow;

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
  }

  .stars {
    // @include badge;

    position: absolute;
    top: 0.5rem;
    right: 0.5rem;

    @include ftsize(sm);
  }

  .stype {
    @include badge;

    position: absolute;
    top: 0.5rem;
    left: 0.5rem;
  }

  .rstate {
    @include badge;
    @include flex-ca;

    position: absolute;
    bottom: 0.5rem;
    left: 0.5rem;
  }

  .stats {
    @include flex-ca;
    position: absolute;
    bottom: 0.5rem;
    right: 0.5rem;
  }

  .chmax,
  .rdlog {
    @include badge;
  }

  .chmax {
    @include bdradi(0, $loc: right);
  }

  .rdlog {
    @include bdradi(0, $loc: left);
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
