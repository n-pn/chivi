<script lang="ts">
  import { get_user } from '$lib/stores'
  const _user = get_user()

  import { get_rtime } from '$gui/atoms/RTime.svelte'
  import SIcon from '$gui/atoms/SIcon.svelte'

  export let ustem: CV.Upstem

  export let chaps: CV.Wnchap[]

  export let bhref: string
</script>

<div class="chaps">
  {#each chaps as chinfo}
    <a href="{bhref}/{chinfo.ch_no}" class="chinfo" rel="nofollow">
      <div class="chap-text">
        <span class="title">{chinfo.title}</span>
        <span class="ch_no">{chinfo.ch_no}.</span>
      </div>
      <div class="chap-meta">
        <span class="chdiv">{chinfo.chdiv || 'Chính văn'}</span>
        {#if chinfo.mtime > 0}
          <span class="meta" data-tip="Lưu: {get_rtime(chinfo.mtime)}">
            <SIcon name="file-download" />
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
    @include fgcolor(neutral, 5);
    @include clamp($width: null);
  }

  .meta {
    @include fgcolor(mute, 5);
    font-size: 0.875rem;
  }
</style>
