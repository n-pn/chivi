<script lang="ts" context="module">
  const mark_types = ['eye', 'bookmark', 'pin']
</script>

<script lang="ts">
  import { chap_path } from '$lib/kit_path'
  import { rel_time } from '$utils/time_utils'

  import SIcon from '$gui/atoms/SIcon.svelte'
  export let items: Array<CV.Tsrepo & CV.Rdmemo>
  export let aside = false

  const seed_icons = {
    '~': 'book',
    '!': 'world',
    '@': 'album',
  }
</script>

<div class="chaps" class:aside>
  {#each items as rmemo}
    <a class="cmemo" href="/ts/{chap_path(rmemo.sroot, rmemo.lc_ch_no, rmemo)}">
      <div class="cname">
        <div class="chead">
          <span class="ch_no">{rmemo.lc_ch_no}.</span>
          <span class="title">{rmemo.lc_title}</span>
        </div>
        <div class="cmeta">
          <SIcon name={seed_icons[rmemo.sname[0]]} />
          <strong class="bname">{rmemo.vname}</strong>
        </div>
      </div>

      <div class="cstat">
        <div class="chead">
          <span class="cmeta">
            <SIcon name={mark_types[rmemo.lc_mtype]} />
            {rel_time(rmemo.vu_rtime || rmemo.rtime || 0)}
          </span>
        </div>
        <div class="cmeta">
          <SIcon name="books" />
          <span class="bname">{rmemo.sname}</span>
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
    display: flex;
    flex-direction: column;

    @include border(--bd-main, $loc: bottom);
    padding: 0.375rem 0.5rem;

    @include bp-min(ts) {
      flex-direction: row;
    }

    .aside & {
      flex-direction: column;
    }

    &:first-child {
      @include border(--bd-main, $loc: top);
    }

    &:nth-child(odd) {
      background-color: var(--bg-main);
    }
  }

  .cname {
    @include bp-min(ts) {
      width: calc(100% - 8rem);
    }

    .aside & {
      width: 100%;
    }
  }

  .cstat {
    @include flex;
    flex-direction: row;
    gap: 0.5rem;

    @include bp-min(ts) {
      flex-direction: column;
      width: 8rem;
      margin-left: auto;
      gap: 0;
    }

    .aside & {
      flex-direction: row;
      width: 100%;
      margin-left: initial;
      gap: 0.5rem;
    }
  }

  .chead {
    @include flex($gap: 0.25rem);
  }

  .ch_no {
    @include fgcolor(tert);
    @include ftsize(sm);
  }

  .title {
    @include fgcolor(secd);
    @include clamp($width: null);

    .cmemo:visited & {
      @include fgcolor(neutral, 5);
    }

    .cmemo:hover & {
      @include fgcolor(primary, 5);
    }
  }

  .cmeta {
    @include flex-ca($gap: 0.25rem);
    @include ftsize(sm);
    @include fgcolor(tert);

    :global(svg) {
      @include fgcolor(mute);
      font-size: 1.2em;
    }
  }

  .bname {
    flex: 1 1;
    text-transform: uppercase;
    @include clamp($width: null);
    @include ftsize(xs);
  }
</style>
