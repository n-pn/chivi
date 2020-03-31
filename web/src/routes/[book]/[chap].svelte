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
    let res = ''

    for (const tok of tokens) {
      switch (tok[1].charAt(0)) {
        case '⟨':
          res += '<cite>'
          break
        case '“':
          res += '<em>'
          break
      }

      if (active) res += `<v k="${tok[0]}" d="${tok[2]}">${tok[1]}</v>`
      else res += tok[1]

      switch (tok[1].charAt(tok[1].length - 1)) {
        case '⟩':
          res += '</cite>'
          break
        case '”':
          res += '</em>'
          break
      }
    }

    return res
  }
</script>

<script>
  import MIcon from '$mould/shared/MIcon.svelte'
  import Header from '$mould/layout/Header.svelte'
  import LinkBtn from '$mould/layout/header/LinkBtn.svelte'
  import Wrapper from '$mould/layout/Wrapper.svelte'

  export let book_slug
  export let book_name
  export let prev_slug
  export let next_slug
  export let curr_slug

  export let lines
  export let chidx
  export let total

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
        if (prev_slug) _goto(`${book_slug}/${prev_slug}`)
        else _goto(book_slug)

        break

      case 39:
      case 75:
        if (next_slug) _goto(`${book_slug}/${next_slug}`)
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
    // background-color: #fff;
    // margin: 0.75rem 0;
    // @include radius;
    // @include shadow(1);

    @include responsive-gap();
  }

  h1 {
    @include border($side: bottom);

    font-size: rem(20px);
    line-height: 1.75rem;

    @include screen-min(md) {
      font-size: rem(22px);
      line-height: 2rem;
    }

    @include screen-min(lg) {
      font-size: rem(24px);
      line-height: 2.25rem;
    }

    @include screen-min(xl) {
      font-size: rem(30px);
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

  :global(cite) {
    text-transform: capitalize;
    font-style: normal;
    // font-variant: small-caps;
  }

  footer {
    margin: 0.75rem 0;
    display: flex;
    justify-content: center;
    [m-button] {
      margin-left: 0.5rem;
    }
  }

  :global(v) {
    border-bottom: 1px solid transparent;

    &[d='1'] {
      border-bottom-color: color(blue, 3);
      cursor: pointer;
      @include hover {
        color: color(blue, 6);
      }
    }

    &[d='2'] {
      border-bottom-color: color(teal, 3);
      cursor: pointer;
      @include hover {
        color: color(teal, 6);
      }
    }

    &[d='3'] {
      border-bottom-color: color(red, 3);
      cursor: pointer;
      @include hover {
        color: color(red, 6);
      }
    }

    &[d='4'] {
      border-color: color(orange, 3);
      cursor: pointer;
      @include hover {
        color: color(orange, 6);
      }
    }
  }

  .index {
    padding: 0 0.375rem;
    @include truncate(25vw);
  }
</style>

<svelte:head>
  <title>{render(lines[0])} - {book_name} - Chivi</title>
</svelte:head>

<svelte:window on:keydown={navigate} />

<Header>
  <div class="left">
    <LinkBtn href="/">
      <img src="/logo.svg" alt="logo" />
    </LinkBtn>

    <LinkBtn href="/{book_slug}" class="active">
      <span>{book_name}</span>
    </LinkBtn>

    <!-- <LinkBtn href="/{book_slug}/{curr_slug}"> -->
    <span class="index">Ch {chidx}/{total}</span>
    <!-- </LinkBtn> -->
  </div>
  <div class="right">
    <LinkBtn href="/{book_slug}/{curr_slug}?reload=true">
      <MIcon m-icon="refresh-ccw" />
    </LinkBtn>
  </div>
</Header>

<Wrapper>
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
</Wrapper>
