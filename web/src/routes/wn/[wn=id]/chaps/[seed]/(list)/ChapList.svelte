<script lang="ts">
  import { get_user } from '$lib/stores'
  import { seed_path } from '$lib/kit_path'

  import { get_rtime } from '$gui/atoms/RTime.svelte'
  import SIcon from '$gui/atoms/SIcon.svelte'

  export let nvinfo: CV.Wninfo
  export let ubmemo: CV.Ubmemo

  export let curr_seed: CV.Chroot
  export let seed_data: CV.Wnseed

  export let chaps: CV.Wnchap[]

  export let mark_chidx = ubmemo.chidx

  $: same_sname = curr_seed.sname == ubmemo.sname

  $: base_url = seed_path(nvinfo.bslug, curr_seed.sname)

  const _user = get_user()

  function map_privi(ch_no: number): string[] {
    let min = seed_data.read_privi
    if (ch_no <= seed_data.gift_chaps) min -= 1

    if ($_user.privi >= min) {
      return ['Bạn đủ quyền xem chương', 'lock-open', 'tabler']
    } else if (min < 1) {
      return ['Bạn cần đăng nhập để xem chương', 'lock', 'tabler']
    } else {
      return [`Cần quyền hạn ${min} để xem chương`, `privi-${min}`, 'sprite']
    }
  }
</script>

{#key curr_seed.sname}
  <div class="chaps">
    {#each chaps as chinfo}
      {@const [lock_text, lock_icon, lock_iset] = map_privi(chinfo.chidx)}

      <a
        href="{base_url}/{chinfo.chidx}/{chinfo.uslug}-mt"
        class="chinfo"
        class:_active={chinfo.chidx == mark_chidx}
        rel={curr_seed.sname != '_' ? 'nofollow' : null}>
        <div class="chap-text">
          <chap-title>{chinfo.title}</chap-title>
          <chap-chidx>{chinfo.chidx}.</chap-chidx>
        </div>
        <div class="chap-meta">
          <chap-chvol>{chinfo.chvol || 'Chính văn'}</chap-chvol>
          {#if chinfo.utime > 0}
            <chap-track
              data-tip="Lưu: {get_rtime(chinfo.utime)} bởi {chinfo.uname ||
                '?'}">
              <SIcon name="file-download" />
            </chap-track>
          {/if}

          {#if same_sname && chinfo.chidx == ubmemo.chidx}
            <chap-mark data-tip="Xem: {get_rtime(ubmemo.utime)}">
              <SIcon name={ubmemo.locked ? 'bookmark' : 'eye'} />
            </chap-mark>
          {/if}

          <chap-mark data-tip={lock_text}
            ><SIcon name={lock_icon} iset={lock_iset} /></chap-mark>
        </div>
      </a>
    {/each}
  </div>
{/key}

<style lang="scss">
  $chap-size: 17.5rem;
  // $chap-break: $chap-size * 2 + 0.75 * 5;

  .chaps {
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
  }
</style>
