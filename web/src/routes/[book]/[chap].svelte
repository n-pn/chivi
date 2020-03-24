<script context="module">
  export async function preload({ params }) {
    const book = params.book
    const slug = params.chap.split('-')[0]

    const res = await this.fetch(`api/chaps/${book}/${slug}`)
    const data = await res.json()

    if (!!data.book_name) {
      return data
    } else {
      this.error(404, 'Chap not found!')
    }
  }
</script>

<script>
  export let prev
  export let next
  // export let zh_lines
  export let vi_lines
  export let book_slug
  export let book_name

  import MIcon from '$mould/MIcon.svelte'

  function navigate(evt) {
    switch (evt.keyCode) {
      case 82:
        _goto(book_slug)
        evt.preventDefault()
        break
      case 37:
        if (prev) _goto(`${book_slug}/${prev.uid}-${prev.url_slug}`)
        else _goto(`${book_slug}`)
        evt.preventDefault()

        break

      case 39:
        if (next) _goto(`${book_slug}/${next.uid}-${next.url_slug}`)
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
    @include font-size(2);

    @include screen-min(md) {
      @include font-size(3);
    }

    @include screen-min(xl) {
      @include font-size(4);
    }

    margin-top: 1rem;
  }

  footer {
    margin: 1rem 0;
    // display: flex;
    // justify-content: center;
    // [m-button] {
    //   margin-left: 0.5rem;
    // }
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
</style>

<svelte:head>
  <title>{vi_lines[0]} - {book_name} - Chivi</title>
</svelte:head>

<svelte:window on:keydown={navigate} />

<div class="bread">
  <span class="crumb">
    <a class="crumb-link" href="/">Home</a>
  </span>
  <span class="crumb">
    <a class="crumb-link" href="/{book_slug}">{book_name}</a>
  </span>
  <span class="crumb">{vi_lines[0]}</span>

</div>

<article>
  {#each vi_lines as line, idx}
    {#if idx == 0}
      <h1 class="vi">{line}</h1>
    {:else}
      <p class="vi">{line}</p>
    {/if}
  {/each}
</article>

<footer class="u-cf">
  {#if prev}
    <a
      class="u-fl"
      m-button="line"
      href="/{book_slug}/{prev.uid}-{prev.url_slug}">
      <MIcon m-icon="chevron-left" />
      <span>Prev</span>
    </a>
  {/if}

  {#if next}
    <a
      class="u-fr"
      m-button="primary"
      href="/{book_slug}/{next.uid}-{next.url_slug}">
      <span>Next</span>
      <MIcon m-icon="chevron-right" />
    </a>
  {/if}
</footer>
