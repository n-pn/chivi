<script>
  import SIcon from '$atoms/SIcon.svelte'

  export let bslug = ''
  export let sname = ''

  export let chaps = []
  export let track = {}
</script>

<div class="list">
  {#each chaps as { chidx, title, chvol, uslug, parts }}
    <div class="list-item">
      <a
        href="/-{bslug}/-{sname}/-{uslug}-{chidx}"
        class="chap"
        class:_active={chidx == track.chidx}>
        <div class="chap-text">
          <div class="chap-title">{title}</div>
          <div class="chap-chidx">{chidx}.</div>
        </div>
        <div class="chap-meta">
          <div class="chap-chvol">{chvol}</div>
          {#if chidx == track.chidx && sname == track.sname}
            <div class="chap-track">
              <SIcon name={track.locked ? 'bookmark' : 'eye'} />
            </div>
          {:else if parts > 0}
            <div class="chap-track">
              <SIcon name="device-floppy" />
            </div>
          {/if}
        </div>
      </a>
    </div>
  {/each}
</div>

<style lang="scss">
  $chap-size: 17.5rem;
  // $chap-break: $chap-size * 2 + 0.75 * 5;

  .list {
    @include grid($size: minmax(var(--size, 17.5rem), 1fr));
    @include bps(--size, 17.75rem, $md: 16.25rem, $lg: 17.75rem);

    grid-gap: 0 var(--gutter-sm);
  }

  .list-item {
    display: block;
    @include border(--bd-main, $loc: bottom);
    $bg-dark: color(neutral, 8);

    &:first-child {
      @include border(--bd-main, $loc: top);
    }

    &:nth-child(odd) {
      @include bgcolor(secd);
    }

    @include bp-min(md) {
      &:nth-child(2) {
        @include border(--bd-main, $loc: top);
      }

      &:nth-child(4n),
      &:nth-child(4n + 1) {
        @include bgcolor(secd);
      }

      &:nth-child(4n + 2),
      &:nth-child(4n + 3) {
        @include bgcolor(tert);
      }
    }
  }

  .chap {
    display: block;
    padding: 0.375rem 0.5rem;

    // prettier-ignore
    &._active {
      @include bgcolor(primary, 2, 3);
      @include tm-dark { @include bgcolor(primary, 8, 3); }
    }
  }

  .chap-text {
    display: flex;
    line-height: 1.5rem;
  }

  .chap-meta {
    display: flex;
    padding: 0;
    height: 1rem;
    line-height: 1rem;
    margin-top: 0.25rem;
    text-transform: uppercase;
    @include ftsize(xs);
  }

  // prettier-ignore
  .chap-title {
    flex: 1;
    @include clamp($width: null);
    @include fgcolor(secd);

    .chap:visited & { @include fgcolor(tert); }
    .chap:hover & { @include fgcolor(primary, 5); }
  }

  .chap-chidx {
    margin-left: 0.125rem;
    user-select: none;
    @include fgcolor(neutral, 5);
    @include ftsize(xs);
  }

  .chap-chvol {
    flex: 1;
    @include fgcolor(neutral, 5);
    @include clamp($width: null);
  }

  .chap-track {
    @include fgcolor(neutral, 5);
    font-size: 1rem;
  }
</style>
