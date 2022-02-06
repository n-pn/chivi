<script>
  import { session } from '$app/stores'
  import { status_names, status_icons } from '$lib/constants'

  import { kit_chap_url } from '$lib/utils/route_utils'

  import SIcon from '$atoms/SIcon.svelte'
  import { onMount } from 'svelte'

  let chaps = []
  onMount(load_history)

  async function load_history(pg = 1) {
    const api_url = `/api/_self/books/access?pg=${pg}&lm=10`
    const api_res = await fetch(api_url)
    const payload = await api_res.json()
    if (api_res.ok) chaps = payload.props
  }
</script>

<div class="chips">
  {#each ['reading', 'onhold', 'pending'] as status}
    <a href="/books/@{$session.uname}?bmark={status}" class="chip">
      <span class="chip-icon">
        <SIcon name={status_icons[status]} />
      </span>
      <span class="chip-text">
        {status_names[status]}
      </span>
    </a>
  {/each}
</div>

<div class="label">
  <SIcon name="clock" />
  <span>Lịch sử đọc</span>
</div>

<chap-list>
  {#each chaps as chap}
    <a class="chap" href={kit_chap_url(chap.bslug, chap)}>
      <div class="chap-text">
        <div class="chap-title">{chap.title}</div>
        <div class="chap-chidx">{chap.chidx}.</div>
      </div>

      <div class="chap-meta">
        <div class="chap-bname">{chap.bname}</div>

        {#if chap.locked}
          <div class="chap-icon"><SIcon name="bookmark" /></div>
        {/if}
      </div>
    </a>
  {/each}
</chap-list>

<style lang="scss">
  @mixin label {
    font-weight: 500;
    text-transform: uppercase;
    @include fgcolor(tert);
  }

  .label {
    @include flex();
    margin: 0.25rem 0.375rem;
    padding: 0 0.5rem;

    line-height: 2.25rem;
    font-weight: 500;

    color: var(--fg-tert);

    :global(svg) {
      margin-top: 0.625rem;
      width: 1rem;
      height: 1rem;
    }

    span {
      margin-left: 0.25rem;
    }
  }

  .chips {
    @include flex($center: horz);
    padding: 0.75rem;
    padding-bottom: 0;

    @include bps(font-size, 12px, 12px, 13px);
  }

  .chip {
    display: inline-flex;
    border-radius: 0.75rem;
    padding: 0 0.75em;
    line-height: 2.25em;

    @include label();
    @include bgcolor(tert);
    @include linesd(var(--bd-main));

    &:hover {
      @include linesd(primary, 4, $ndef: false);
      @include fgcolor(primary, 5);
    }

    @include tm-dark {
      &:hover {
        @include linesd(primary, 5, $ndef: false);
        @include fgcolor(primary, 4);
      }
    }

    & + & {
      @include bps(margin-left, 0.25rem, 0.375rem);
    }
  }

  .chip-icon {
    margin-top: 0.5em;
    margin-right: 0.375em;

    > :global(svg) {
      display: block;
      width: 1.25em;
      height: 1.25em;
    }
  }

  .chip-text {
    @include clamp($width: null);
  }

  chap-list {
    display: block;
    margin-bottom: 1rem;
  }

  .chap {
    display: block;
    margin: 0 0.75rem;
    @include border(--bd-main, $loc: bottom);

    padding: 0.375rem 0.5rem;
    user-select: none;

    &:first-child {
      @include border(--bd-main, $loc: top);
    }

    &:nth-child(odd) {
      background: var(--bg-main);
    }
  }

  // prettier-ignore
  .chap-title {
    flex: 1;
    margin-right: 0.125rem;
    @include fgcolor(secd);
    @include clamp($width: null);

    .chap:visited & { @include fgcolor(neutral, 5); }
    .chap:hover & { @include fgcolor(primary, 5); }
  }

  .chap-text {
    display: flex;
    line-height: 1.5rem;
  }

  .chap-meta {
    @include flex($gap: 0.25rem);
    padding: 0;
    line-height: 1rem;
    margin-top: 0.25rem;
    text-transform: uppercase;

    @include ftsize(xs);
    @include fgcolor(neutral, 5);
    @include clamp($width: null);
  }

  .chap-chidx {
    @include fgcolor(tert);
    @include ftsize(xs);
  }

  .chap-icon {
    @include fgcolor(tert);
    // height: 0.8rem;
    margin-left: auto;
    font-size: 1rem;
    margin-top: -0.125rem;
  }

  .chap-bname {
    @include clamp($width: null);
  }
</style>
