<script context="module">
  export function paginate(chaps, focus, limit = 50) {
    let offset = (focus - 1) * limit
    if (offset < 0) offset = 0
    return chaps.slice(offset, offset + limit)
  }

  export function page_url(slug, site, page = 1) {
    return `/${slug}?tab=content&site=${site}&page=${page}`
  }
</script>

<script>
  import MIcon from '$mould/MIcon.svelte'
  import paginate_range from '$utils/paginate_range'

  export let chaps = []
  export let bslug = ''
  export let sname = ''
  export let focus = 1
  export let limit = 30

  let scroll = null

  $: items = paginate(chaps, focus, limit)
  $: total = Math.floor((chaps.length - 1) / limit) + 1
  $: range = paginate_range(focus, total)

  function changeFocus(newFocus) {
    focus = newFocus
    scroll.scrollIntoView({ behavior: 'smooth', block: 'start' })
    // window.scrollBy(0, -20)
  }
</script>

<div class="chap" data-site={sname} id="chap" bind:this={scroll}>
  <ul class="chap-list">
    {#each items as chap}
      <li class="chap-item">
        <a
          class="chap-link"
          href="/{bslug}/{chap.url_slug}"
          rel="nofollow prefetch">
          <span class="volume">{chap.vi_volume}</span>
          <span class="title">{chap.vi_title}</span>
        </a>
      </li>
    {/each}
  </ul>

</div>

<div class="pagi">
  <button
    class="page m-button _line"
    on:click={() => changeFocus(1)}
    disabled={focus == 1}>
    <MIcon class="m-icon" name="chevrons-left" />
  </button>

  {#each range as index}
    <button
      class="page m-button _line"
      disabled={focus == index}
      on:click={() => changeFocus(index)}>
      <span>{index}</span>
    </button>
  {/each}

  <button
    class="page m-button _line"
    disabled={focus == total}
    on:click={() => changeFocus(total)}>
    <MIcon class="m-icon" name="chevrons-right" />
  </button>
</div>

<style type="text/scss">
  .volume {
    padding-top: 0.5rem;
    padding-left: 0.5rem;
  }

  $chap-size: 17.5rem;
  $chap-break: $chap-size * 2 + 0.75 * 5;

  .chap-list {
    @include grid($size: minmax($chap-size, 1fr), $gap: 0 0.75rem);
  }

  .chap-item {
    display: block;

    @include border($pos: bottom);

    &:first-child {
      @include border($pos: top);
    }

    &:nth-child(even) {
      background-color: color(neutral, 1);
    }

    @include screen-min($chap-break) {
      &:nth-child(2) {
        @include border($pos: top);
      }

      &:nth-child(4n),
      &:nth-child(4n + 1) {
        background-color: #fff;
      }

      &:nth-child(4n + 2),
      &:nth-child(4n + 3) {
        background-color: color(neutral, 1);
      }
    }
  }

  .chap-link {
    display: block;
    padding: 0.375rem 0.75rem;

    &:visited {
      .title {
        font-style: italic;
        @include fgcolor(color(neutral, 5));
      }
    }

    @include hover {
      .title {
        @include fgcolor(color(primary, 5));
      }
    }
  }

  .volume {
    display: block;
    padding: 0;
    line-height: 1.25rem;
    @include font-size(1);
    text-transform: uppercase;
    @include fgcolor(color(neutral, 5));
    @include truncate(100%);
  }

  .title {
    display: block;
    padding: 0;
    line-height: 1.5rem;
    @include fgcolor(color(neutral, 8));
    @include truncate(100%);
  }

  .pagi {
    margin-top: 0.75rem;
    display: flex;
    justify-content: center;
  }

  .page {
    // :global(.main._clear) & {
    //   @include bgcolor(color(neutral, 2));
    // }
    &:disabled {
      cursor: text;
    }
    & + & {
      margin-left: 0.375rem;
    }
  }
</style>
