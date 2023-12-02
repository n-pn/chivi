<script lang="ts" context="module">
  const stypes = [
    ['', 'Không phân loại'],
    ['wn', 'Truyện chữ'],
    ['up', 'Sưu tầm'],
    ['rm', 'Nguồn nhúng'],
  ]

  const mark_types = ['eye', 'bookmark', 'pin']
</script>

<script lang="ts">
  import { chap_path } from '$lib/kit_path'
  import { get_rtime } from '$gui/atoms/RTime.svelte'

  import SIcon from '$gui/atoms/SIcon.svelte'
  export let items: CV.Tsrepo[]
</script>

<div class="chaps">
  {#each items as rmemo}
    <a class="cmemo" href="/ts/{chap_path(rmemo.sroot, rmemo.lc_ch_no, rmemo)}">
      <div class="chead">
        <div class="title">{rmemo.lc_title}</div>
        <div class="ch_no">{rmemo.lc_ch_no}.</div>
      </div>

      <div class="cmeta">
        <div class="bname">
          [{rmemo.sname}] {rmemo.vname}
        </div>
        <div
          class="state"
          data-tip="Xem: {get_rtime(rmemo.rtime)}"
          data-tip-pos="right">
          <SIcon name={mark_types[rmemo.lc_mtype]} />
        </div>
      </div>
    </a>
  {:else}
    <div class={$$props.emty_class || 'd-empty-sm'}>
      Không có lịch sử đọc truyện
    </div>
  {/each}
</div>

<style lang="scss">
  .cmemo {
    display: block;
    @include border(--bd-main, $loc: bottom);

    padding: 0.375rem 0.5rem;
    user-select: none;

    &:first-child {
      @include border(--bd-main, $loc: top);
    }

    &:nth-child(odd) {
      background: var(--bg-main);
    }
  }

  .title {
    flex: 1;
    margin-right: 0.125rem;
    @include fgcolor(secd);
    @include clamp($width: null);

    .cmemo:visited & {
      @include fgcolor(neutral, 5);
    }
    .cmemo:hover & {
      @include fgcolor(primary, 5);
    }
  }

  .chead {
    display: flex;
    line-height: 1.5rem;
  }

  .cmeta {
    @include flex($gap: 0.25rem);
    padding: 0;
    line-height: 1rem;
    margin-top: 0.25rem;
    text-transform: uppercase;

    @include ftsize(xs);
    @include fgcolor(neutral, 5);
  }

  .ch_no {
    @include fgcolor(tert);
    @include ftsize(xs);
  }

  .state {
    @include fgcolor(tert);
    position: relative;
    font-size: 1rem;
    margin-top: -0.125rem;
  }

  .bname {
    flex: 1 1;
    @include clamp($width: null);
  }
</style>
