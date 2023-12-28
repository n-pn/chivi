<script lang="ts">
  import { get_rtime } from '$gui/atoms/RTime.svelte'
  import SIcon from '$gui/atoms/SIcon.svelte'

  export let chaps: CV.Wnchap[]
  export let bhref: string
</script>

<div class="chaps">
  {#each chaps as chinfo}
    <a href="{bhref}/c{chinfo.ch_no}" class="chinfo" rel="nofollow">
      <div class="chap-text">
        <span class="title">{chinfo.title}</span>
        <span class="ch_no">{chinfo.ch_no}.</span>
      </div>
      <div class="chap-meta">
        <span class="chdiv">{chinfo.chdiv || 'Chính văn'}</span>
        {#if chinfo.mtime > 0}
          <span class="mtime">
            <SIcon name="file-download" />
            <span>{get_rtime(chinfo.mtime)}</span>
          </span>
        {/if}
      </div>
    </a>
  {/each}
</div>

<style lang="scss">
  $chap-size: 17.5rem;
  // $chap-break: $chap-size * 2 + 0.75 * 5;

  .chinfo {
    display: block;
    padding: 0.375rem 0.5rem;

    @include border(--bd-soft, $loc: bottom);
    $bg-dark: color(neutral, 8);

    &:first-child {
      @include border(--bd-soft, $loc: top);
    }

    &:nth-child(odd) {
      @include bgcolor(secd);
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
    @include ftsize(xs);
  }

  // prettier-ignore
  .title {
    flex: 1;
    @include clamp($width: null);
    @include fgcolor(secd);

    .chinfo:visited & { @include fgcolor(tert); }
    .chinfo:hover & { @include fgcolor(primary, 5); }
  }

  .ch_no {
    margin-left: 0.125rem;
    user-select: none;
    @include fgcolor(neutral, 5);
    @include ftsize(xs);
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
    > span {
      @include ftsize(xs);
    }
  }
</style>
