<script lang="ts">
  import { rel_time } from '$utils/time_utils'

  import SIcon from '$gui/atoms/SIcon.svelte'

  export let zsize = 0
  export let mtime = 0
  export let pdict = ''
  export let dsize = [0, 0, 0]
</script>

<section class="status">
  <div class="group">
    <span class="entry" data-tip="Số chữ tiếng Trung">
      <SIcon name="file-analytics" />
      <span class="value">{zsize}</span>
      <span class="label"> chữ</span>
    </span>

    {#if pdict}
      <a
        href="/mt/dicts/{pdict.replace('/', ':')}"
        class="entry"
        data-tip="Dữ liệu từ điển dịch máy">
        <SIcon name="package" />
        <span class="value">{dsize[0]} + {dsize[2]}</span>
      </a>
    {/if}

    {#if mtime}
      <div class="entry" data-tip="Thay đổi lần cuối">
        <SIcon name="calendar" />
        <span class="value">{rel_time(mtime)}</span>
      </div>
    {/if}
  </div>
</section>

<style lang="scss">
  .status {
    margin-bottom: 0.75rem;
    @include flex-cx;
    // justify-content: right;
  }

  .group {
    @include flex-cx;
    @include padding-x(0.75rem);
    // @include padding-y(0.25rem);

    @include border(--bd-soft, $loc: bottom);
    @include ftsize(sm);
    @include fgcolor(mute);
  }

  .entry {
    display: inline-flex;
    align-items: center;

    & + &:before {
      content: ' ';
      margin: 0 0.25rem;
    }
  }

  .label {
    display: none;
    font-style: italic;

    @include bp-min(ts) {
      display: inline-block;

      .value + & {
        margin-left: 0.125rem;
      }
      & + :global(svg) {
        display: none;
      }
    }
  }

  .value {
    margin-left: 0.125rem;
    // font-weight: 500;
    @include fgcolor(tert);
  }

  a {
    &:hover {
      @include fgcolor(primary, 5);
    }
  }
</style>
