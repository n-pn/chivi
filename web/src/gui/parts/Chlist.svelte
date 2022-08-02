<script lang="ts">
  import { session } from '$app/stores'
  import { get_rtime } from '$gui/atoms/RTime.svelte'
  import { SIcon } from '$gui'

  export let nvinfo: CV.Nvinfo
  export let nvseed: CV.Chroot
  export let ubmemo: CV.Ubmemo
  export let chlist: CV.Chinfo[]
  export let mark_chidx = ubmemo.chidx

  $: same_sname = nvseed.sname == ubmemo.sname

  function check_privi({ chidx, chars }): number {
    if (chidx <= nvseed.free_chap) return nvseed.privi_map[0]
    else if (chars > 0) return nvseed.privi_map[1]
    else return nvseed.privi_map[2]
  }

  $: base_url = `/-${nvinfo.bslug}/chaps/${nvseed.sname}`
  $: saved_icon = nvseed.stype > 2 ? 'cloud-download' : 'device-floppy'
</script>

<div class="chlist">
  {#each chlist as chinfo}
    {@const min_privi = check_privi(chinfo)}

    <a
      href="{base_url}/{chinfo.chidx}/{chinfo.uslug}"
      class="chinfo umami--click--chlist-toread"
      class:_active={chinfo.chidx == mark_chidx}
      rel={nvseed.sname != '=base' ? 'nofollow' : null}>
      <div class="chap-text">
        <chap-title>{chinfo.title}</chap-title>
        <chap-chidx>{chinfo.chidx}.</chap-chidx>
      </div>
      <div class="chap-meta">
        <chap-chvol>{chinfo.sname} - {chinfo.chvol}</chap-chvol>
        {#if chinfo.chars > 0}
          <chap-track
            data-tip="Lưu: {get_rtime(chinfo.utime)} bởi {chinfo.uname || '?'}">
            <SIcon name={saved_icon} />
          </chap-track>
        {/if}

        {#if same_sname && chinfo.chidx == ubmemo.chidx}
          <chap-mark data-tip="Xem: {get_rtime(ubmemo.utime)}">
            <SIcon name={ubmemo.locked ? 'bookmark' : 'eye'} />
          </chap-mark>
        {/if}

        {#if $session.privi >= min_privi}
          {#if min_privi > -1}
            <chap-mark data-tip="Bạn đủ quyền xem chương"
              ><SIcon name="lock-open" /></chap-mark>
          {:else}
            <chap-mark data-tip="Chương tiết miễn phí"
              ><SIcon name="lock-open" /></chap-mark>
          {/if}
        {:else if min_privi == 0}
          <chap-mark data-tip={'Bạn cần đăng nhập để xem chương'}
            ><SIcon name="lock" /></chap-mark>
        {:else}
          <chap-mark data-tip={`Cần quyền hạn ${min_privi} để xem chương`}
            ><SIcon name="privi-{min_privi}" iset="sprite" /></chap-mark>
        {/if}
      </div>
    </a>
  {/each}
</div>

<style lang="scss">
  $chap-size: 17.5rem;
  // $chap-break: $chap-size * 2 + 0.75 * 5;

  .chlist {
    display: grid;
    width: 100%;
    grid-gap: 0 var(--gutter-pl);

    @include bps(
      grid-template-columns,
      100%,
      $tm: repeat(auto-fill, minmax(20rem, 1fr))
    );
  }

  .chinfo {
    display: block;
    padding: 0.375rem 0.5rem;

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
  chap-title {
    flex: 1;
    @include clamp($width: null);
    @include fgcolor(secd);

    .chinfo:visited & { @include fgcolor(tert); }
    .chinfo:hover & { @include fgcolor(primary, 5); }
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
    @include fgcolor(mute);
    &.sm {
      font-size: rem(12px);
    }
  }
</style>
