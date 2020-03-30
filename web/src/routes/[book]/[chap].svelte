<script context="module">
  export async function preload({ params }) {
    const book = params.book

    const slug = params.chap.split('-')
    const site = slug[slug.length - 2]
    const chap = slug[slug.length - 1]

    try {
      const res = await this.fetch(`api/books/${book}/${site}/${chap}`)
      const data = await res.json()
      return data
    } catch (err) {
      this.error(404, data.msg)
    }
  }

  export function render(tokens, active = false) {
    if (active) {
      return tokens.map(t => `<v k="${t[0]}" d="${t[2]}">${t[1]}</v>`).join('')
    } else {
      return tokens.map(t => t[1]).join('')
    }
  }
</script>

<script>
  import MIcon from '$mould/shared/MIcon.svelte'

  export let book_slug
  export let book_name
  export let prev_slug
  export let next_slug

  export let lines

  let cur = 0

  // let scroll_ended = false

  // function scrolled(evt) {
  //   scroll_ended = false
  // }

  function navigate(evt) {
    switch (evt.keyCode) {
      // case 32:
      //   if (scroll_ended) {
      //     evt.preventDefault()
      //     if (next) _goto(`${book_slug}/${next.uid}-${next.url_slug}`)
      //     else _goto(book_slug)
      //   } else {
      //     scroll_ended = true
      //   }

      //   break

      case 72:
        evt.preventDefault()
        _goto(book_slug)
        break

      case 37:
      case 74:
        evt.preventDefault()
        if (prev) _goto(`${book_slug}/${prev_slug}`)
        else _goto(book_slug)

        break

      case 39:
      case 75:
        if (next) _goto(`${book_slug}/${next_slug}`)
        else _goto(`${book_slug}`)
        evt.preventDefault()

        break

      default:
        break
    }
  }
</script>

<style lang="scss">
  @mixin responsive-gap() {
    padding: 0.75rem;

    @include screen-min(md) {
      padding: 1rem;
    }

    @include screen-min(lg) {
      padding: 1.25rem;
    }

    @include screen-min(xl) {
      padding: 1.5rem;
    }
  }

  article {
    background-color: #fff;
    @include radius;
    @include shadow(2);

    @include responsive-gap();
  }

  h1 {
    @include border($side: bottom);

    @include font-size(4);
    line-height: 1.75rem;

    @include screen-min(md) {
      @include font-size(5);
      line-height: 2rem;
    }

    @include screen-min(lg) {
      @include font-size(6);
      line-height: 2.25rem;
    }

    @include screen-min(xl) {
      @include font-size(7);
      line-height: 2.5rem;
    }
  }

  p {
    margin-top: 1rem;
    font-size: rem(17px);

    @include screen-min(md) {
      font-size: rem(18px);
    }

    @include screen-min(lg) {
      font-size: rem(19px);
      margin-top: 1.25rem;
    }

    @include screen-min(xl) {
      font-size: rem(20px);
      margin-top: 1.5rem;
    }
  }

  footer {
    margin: 1rem 0;
    display: flex;
    justify-content: center;
    [m-button] {
      margin-left: 0.5rem;
    }
  }

  .bread {
    line-height: 2.5em;
    // @include responsive-gap();
    padding-left: 0;
    padding-right: 0;
    @include font-size(2);
    @include screen-min(lg) {
      @include font-size(3);
    }
  }

  .crumb {
    padding: 0;
    margin: 0;
    a,
    & {
      @include color(neutral, 5);
    }

    @include hover {
      a {
        cursor: pointer;
        @include color(primary, 5);
      }
    }
    &:after {
      margin-left: 0.25rem;
      @include color(neutral, 4);
      content: '>';
    }
    &:last-child:after {
      display: none;
    }
  }

  :global(v) {
    border-bottom: 1px solid transparent;

    &[d='1'] {
      border-bottom-color: color(blue, 5);
      @include hover {
        cursor: pointer;
        color: color(blue, 6);
      }
    }

    &[d='2'] {
      border-bottom-color: color(teal, 5);
      @include hover {
        cursor: pointer;
        color: color(teal, 6);
      }
    }

    &[d='3'] {
      border-bottom-color: color(red, 5);
      @include hover {
        cursor: pointer;
        color: color(red, 6);
      }
    }

    &[d='4'] {
      border-color: color(orange, 5);
      @include hover {
        cursor: pointer;
        color: color(orange, 6);
      }
    }
  }
</style>

<svelte:head>
  <title>{render(lines[0])} - {book_name} - Chivi</title>
</svelte:head>

<svelte:window on:keydown={navigate} />

<div class="bread">
  <span class="crumb">
    <a class="crumb-link" href="/">Home</a>
  </span>
  <span class="crumb">
    <a class="crumb-link" href="/{book_slug}">{book_name}</a>
  </span>
  <span class="crumb">{render(lines[0])}</span>

</div>

<article>
  {#each lines as line, idx}
    {#if idx == 0}
      <h1 class:_active={idx == cur} on:mouseenter={() => (cur = idx)}>
        {@html render(line, idx == cur)}
      </h1>
    {:else}
      <p class:_active={idx == cur} on:mouseenter={() => (cur = idx)}>
        {@html render(line, idx == cur)}
      </p>
    {/if}
  {/each}
</article>

<footer>
  {#if prev_slug}
    <a m-button="line" href="/{book_slug}/{prev_slug}">
      <MIcon m-icon="chevron-left" />
      <span>Prev</span>
    </a>
  {:else}
    <a m-button="line" href="/{book_slug}">
      <MIcon m-icon="list" />
      <span>Home</span>
    </a>
  {/if}

  {#if next_slug}
    <a m-button="line primary" href="/{book_slug}/{next_slug}">
      <span>Next</span>
      <MIcon m-icon="chevron-right" />
    </a>
  {:else if prev_slug}
    <a m-button="line" href="/{book_slug}">
      <MIcon m-icon="list" />
      <span>Home</span>
    </a>
  {/if}
</footer>
