<script lang="ts">
  import { kit_chap_url } from '$utils/route_utils'
  import SIcon from '$gui/atoms/SIcon.svelte'
  import { get_rtime } from '$gui/atoms/RTime.svelte'

  export let bslug = ''
  export let sname = ''
  export let is_remote = false

  export let chaps = []
  export let track

  $: same_sname = sname == track.sname

  function is_marked(chap) {
    return chap.chidx == track.chidx
  }

  function track_cpart(chap) {
    return same_sname && is_marked(chap) ? track.cpart : 0
  }
</script>

<list-grid>
  {#each chaps as chap}
    <list-item>
      <a
        href={kit_chap_url(bslug, { ...chap, sname, cpart: track_cpart(chap) })}
        class="chap"
        class:_active={is_marked(chap)}
        rel={sname != 'chivi' ? 'nofollow' : ''}>
        <div class="chap-text">
          <chap-title>{chap.title}</chap-title>
          <chap-chidx>{chap.chidx}.</chap-chidx>
        </div>
        <chap-meta>
          <chap-chvol>
            {#if chap.o_sname}{chap.o_sname} - {/if}{chap.chvol}
          </chap-chvol>
          {#if chap.chars > 0}
            <chap-track
              data-tip="Lưu: {get_rtime(chap.utime)} bởi {chap.uname || '??'}">
              <SIcon name={is_remote ? 'cloud-download' : 'device-floppy'} />
            </chap-track>
          {/if}

          {#if same_sname && is_marked(chap)}
            <chap-mark data-tip="Xem: {get_rtime(track.utime)}">
              <SIcon name={track.locked ? 'bookmark' : 'eye'} />
            </chap-mark>
          {/if}
        </chap-meta>
      </a>
    </list-item>
  {/each}
</list-grid>

<style lang="scss">
  $chap-size: 17.5rem;
  // $chap-break: $chap-size * 2 + 0.75 * 5;

  list-grid {
    display: grid;
    width: 100%;
    @include bps(
      grid-template-columns,
      100%,
      $tm: repeat(auto-fill, minmax(20rem, 1fr))
    );

    grid-gap: 0 var(--gutter-pl);
  }

  list-item {
    @include border(--bd-main, $loc: bottom);
    $bg-dark: color(neutral, 8);

    &:first-child {
      @include border(--bd-main, $loc: top);
    }

    &:nth-child(odd) {
      @include bgcolor(secd);
    }

    @include bp-min(tm) {
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
      @include bgcolor(primary, 2, 4);
      @include tm-dark { @include bgcolor(primary, 8, 4); }
    }
  }

  .chap-text {
    display: flex;
    line-height: 1.5rem;
  }

  chap-meta {
    display: flex;
    padding: 0;
    height: 1rem;
    line-height: 1rem;
    margin-top: 0.25rem;
    text-transform: uppercase;
    @include ftsize(xs);
  }

  // prettier-ignore
  chap-title {
    flex: 1;
    @include clamp($width: null);
    @include fgcolor(secd);

    .chap:visited & { @include fgcolor(tert); }
    .chap:hover & { @include fgcolor(primary, 5); }
  }

  chap-chidx {
    margin-left: 0.125rem;
    user-select: none;
    @include fgcolor(neutral, 5);
    @include ftsize(xs);
  }

  chap-chvol {
    flex: 1;
    @include fgcolor(neutral, 5);
    @include clamp($width: null);
  }

  chap-track {
    @include fgcolor(neutral, 5);
    font-size: 1rem;
  }

  chap-mark {
    font-size: 1rem;
    @include fgcolor(neutral, 5);
  }
</style>
