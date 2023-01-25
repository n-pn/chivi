<script lang="ts">
  export let title = 'Untitled'
</script>

<svelte:head>
  <title>{title} - Chivi</title>
</svelte:head>

<article class="article md-post">
  <h1>{title}</h1>
  <slot />
</article>

<style lang="scss">
  article {
    > :global(* + *) {
      margin-top: 1.25rem;
    }

    > :global(li + li) {
      margin-top: 1rem;
    }

    // :global(pre > code) {
    //   word-wrap: break-word;
    //   white-space: break-spaces;
    // }

    :global(.language-zh) {
      line-height: 1.25rem;
      font-size: rem(14px);
    }
  }
</style>
