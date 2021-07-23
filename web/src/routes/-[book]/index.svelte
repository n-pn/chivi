<script context="module">
  export async function load({ context }) {
    return { props: { nvinfo: context.nvinfo } }
  }
</script>

<script>
  import Book from './_book.svelte'

  export let nvinfo
  let short_intro = false
</script>

<Book {nvinfo} nvtab="index">
  <h2>Giới thiệu:</h2>
  <div class="intro" class:_short={short_intro}>
    {#each nvinfo.bintro as para}
      <p>{para}</p>
    {/each}
  </div>
</Book>

<style lang="scss">
  h2 {
    @include tm-dark {
      color: var(--color-gray-5);
    }
  }

  .intro {
    word-wrap: break-word;
    @include fgcolor(neutral, 7);
    // @include fluid(padding, $md: 0 0.75rem);
    @include fluid(font-size, rem(15px), rem(16px), rem(17px));

    @include tm-dark {
      @include fgcolor(neutral, 3);
    }

    &._short {
      height: 20rem;
      overflow-y: scroll;
      scrollbar-width: thin;
      scrollbar-color: color(gray, 8);
    }
  }

  p {
    margin-top: 0.5rem;
  }
</style>
