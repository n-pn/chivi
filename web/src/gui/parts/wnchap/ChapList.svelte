<script lang="ts">
  import { chap_path } from '$lib/kit_path'

  import { get_rtime } from '$gui/atoms/RTime.svelte'
  import SIcon from '$gui/atoms/SIcon.svelte'

  export let crepo: CV.Tsrepo
  export let rmemo: CV.Rdmemo
  export let chaps: CV.Wnchap[]

  const get_owner = ({ uname, rlink }: CV.Wnchap) => {
    if (uname) return uname
    if (!rlink) return crepo.sname

    const hostname = new URL(rlink).hostname
    return hostname.replace(/^www\./, '')
  }
</script>

<div class="chaps">
  {#each chaps as cinfo}
    <a
      href={chap_path(`/ts/${crepo.sroot}`, cinfo.ch_no, rmemo)}
      class="cinfo"
      class:_active={cinfo.ch_no == rmemo.lc_ch_no}
      rel="nofollow">
      <div class="ctext">
        <span class="ch_no">{cinfo.ch_no}.</span>
        <span class="title">{cinfo.title}</span>
        <span class="uname">{get_owner(cinfo)}</span>

        {#if cinfo.ch_no == rmemo.lc_ch_no}
          <span class="cmeta" data-tip="Đã xem: {get_rtime(rmemo.rtime)}">
            <SIcon name={['eye', 'bookmark', 'pin'][rmemo.lc_mtype]} />
          </span>
        {/if}
      </div>

      <div class="cfoot">
        <span class="chdiv">{cinfo.chdiv || 'Chính văn'}</span>

        <span class="mtime" data-tip="Thời gian cập nhật text gốc">
          <SIcon name="clock" />
          {#if cinfo.mtime > 0}
            <span>{get_rtime(cinfo.mtime)}</span>
          {:else if cinfo.rlink}
            <span>N/A <SIcon name="cloud" /></span>
          {:else}
            <span>N/A <SIcon name="cloud-off" /></span>
          {/if}
        </span>

        {#if cinfo.zsize}
          <span class="mtime" data-tip="Số ký tự text gốc"
            ><SIcon name="code" /> {cinfo.zsize}</span>
        {/if}
      </div>
    </a>
  {/each}
</div>

<style lang="scss">
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
    gap: 0.25rem;
    line-height: 1rem;
    margin-top: 0.25rem;
    @include ftsize(xs);
  }

  .ch_no {
    margin-right: 0.125rem;
    user-select: none;
    @include fgcolor(neutral, 5);
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

  .uname {
    text-transform: uppercase;
    @include fgcolor(neutral, 5);
    @include ftsize(xs);
  }

  .cmeta {
    @include fgcolor(neutral, 5);
  }

  .chdiv {
    flex: 1;
    text-transform: uppercase;
    @include fgcolor(neutral, 5);
    @include clamp($width: null);
  }

  .mtime {
    @include flex-ca;
    @include fgcolor(mute, 5);
    gap: 0.125rem;
    font-style: italic;
  }
</style>
