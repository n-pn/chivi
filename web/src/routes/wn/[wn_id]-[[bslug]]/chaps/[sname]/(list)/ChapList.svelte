<script lang="ts">
  import { page } from '$app/stores'

  import { get_rtime } from '$gui/atoms/RTime.svelte'
  import { SIcon } from '$gui'

  export let nvinfo: CV.Nvinfo

  export let nvseed: CV.Chroot

  export let ubmemo: CV.Ubmemo

  export let chaps: CV.Chinfo[]

  export let privi_map: number[] = gen_privi_map(nvseed.sname, nvseed.chmax)

  export let mark_chidx = ubmemo.chidx

  $: same_sname = nvseed.sname == ubmemo.sname

  $: base_url = gen_base_url(nvinfo, nvseed)

  function gen_base_url({ bslug }, { sname, snvid }) {
    const url = `/wn/${bslug}/chaps/${sname}`
    return sname[0] == '!' ? `${url}:${snvid}` : url
  }

  $: _privi = $page.data._user.privi

  function gen_privi_map(sname: string, total: number = 0) {
    const lower = Math.floor(total / 4)
    const upper = total - lower

    if (sname == '-') return [lower, upper, total]
    if (sname[0] == '@') return [0, lower, upper, total]
    if (sname[0] == '!') return [0, 0, lower, upper, total]
    return [0, 0, 0, lower, upper, total]
  }

  function map_privi(ch_no: number) {
    const min = privi_map.findIndex((value) => ch_no <= value) - 1 || 2

    if (min < 0) return ['Chương tiết miễn phí', 'lock-open']
    if (_privi >= min) return ['Bạn đủ quyền xem chương', 'lock-open']

    if (min < 1) return ['Bạn cần đăng nhập để xem chương', 'lock']
    return [`Cần quyền hạn ${min} để xem chương`, `privi-${min}`, 'sprite']
  }
</script>

<div class="chaps">
  {#each chaps as chinfo}
    {@const [lock_text, lock_icon, lock_type] = map_privi(chinfo.chidx)}

    <a
      href="{base_url}/{chinfo.chidx}/{chinfo.uslug}"
      class="chinfo"
      class:_active={chinfo.chidx == mark_chidx}
      rel={nvseed.sname != '-' ? 'nofollow' : null}>
      <div class="chap-text">
        <chap-title>{chinfo.title}</chap-title>
        <chap-chidx>{chinfo.chidx}.</chap-chidx>
      </div>
      <div class="chap-meta">
        <chap-chvol>{chinfo.chvol || 'Chính văn'}</chap-chvol>
        {#if chinfo.utime > 0}
          <chap-track
            data-tip="Lưu: {get_rtime(chinfo.utime)} bởi {chinfo.uname || '?'}">
            <SIcon name="device-floppy" />
          </chap-track>
        {/if}

        {#if same_sname && chinfo.chidx == ubmemo.chidx}
          <chap-mark data-tip="Xem: {get_rtime(ubmemo.utime)}">
            <SIcon name={ubmemo.locked ? 'bookmark' : 'eye'} />
          </chap-mark>
        {/if}

        <chap-mark data-tip={lock_text}
          ><SIcon name={lock_icon} iset={lock_type} /></chap-mark>
      </div>
    </a>
  {/each}
</div>

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
