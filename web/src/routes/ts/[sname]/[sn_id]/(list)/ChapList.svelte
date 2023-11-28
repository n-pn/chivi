<script lang="ts">
  import { chap_path } from '$lib/kit_path'

  import { get_rtime } from '$gui/atoms/RTime.svelte'
  import SIcon from '$gui/atoms/SIcon.svelte'

  export let crepo: CV.Chrepo
  export let rmemo: CV.Rdmemo
  export let chaps: CV.Wnchap[]

  $: ({ lc_ch_no, lc_p_idx } = rmemo)

  const gen_chap_href = (cinfo: CV.Wnchap) => {
    let cpath = `c${cinfo.ch_no}`
    if (cinfo.ch_no == lc_ch_no && lc_p_idx > 1) cpath += `_${lc_p_idx}`
    return chap_path(`/ts/${crepo.sroot}`, cpath, rmemo)
  }
</script>

<div class="chaps">
  {#each chaps as cinfo}
    <a
      href={gen_chap_href(cinfo)}
      class="cinfo"
      class:_active={cinfo.ch_no == rmemo.lc_ch_no}
      rel="nofollow">
      <div class="ctext">
        <span class="title">{cinfo.title}</span>
        <span class="ch_no">{cinfo.ch_no}.</span>
      </div>
      <div class="cfoot">
        <span class="chdiv">{cinfo.chdiv || 'Chính văn'}</span>
        {#if cinfo.mtime > 0}
          <span class="cmeta" data-tip="Lưu: {get_rtime(cinfo.mtime)}">
            <SIcon name="file-download" />
          </span>
        {:else if cinfo.rlink}
          <span class="cmeta" data-tip="Liên kết: {cinfo.rlink}">
            <SIcon name="external-link" />
          </span>
        {:else}
          <span class="cmeta" data-tip="Dữ liệu có khả năng không tồn tại!">
            <SIcon name="skull" />
          </span>
        {/if}

        {#if cinfo.ch_no == rmemo.lc_ch_no}
          <span class="cmeta" data-tip="Đã xem: {get_rtime(rmemo.rtime)}">
            <SIcon name={['eye', 'bookmark', 'pin'][rmemo.lc_mtype]} />
          </span>
        {/if}
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

  .cinfo {
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

  .ctext {
    display: flex;
    line-height: 1.5rem;
  }

  .cfoot {
    display: flex;
    padding: 0;
    height: 1rem;
    line-height: 1rem;
    margin-top: 0.25rem;
    text-transform: uppercase;
    @include ftsize(xs);
  }

  // prettier-ignore
  .title {
    flex: 1;
    @include clamp($width: null);
    @include fgcolor(secd);

    .cinfo:visited & { @include fgcolor(tert); }
    .cinfo:hover & { @include fgcolor(primary, 5); }
  }

  .ch_no {
    margin-left: 0.125rem;
    user-select: none;
    @include fgcolor(neutral, 5);
    @include ftsize(xs);
  }

  .chdiv {
    flex: 1;
    @include fgcolor(neutral, 5);
    @include clamp($width: null);
  }

  .cmeta {
    @include fgcolor(mute, 5);
    font-size: 0.875rem;
  }
</style>
