<script>
  import { SIcon } from '$gui'
  export let tree = []
</script>

<nav class="bread">
  <a class="crumb _link" href="/">
    <SIcon name="home" />
  </a>
  {#each tree as [text, href, opts]}
    <span class="sep">/</span>
    <a {href} class="crumb" {...opts}>{text} </a>
  {/each}
</nav>

<style lang="scss">
  .bread {
    padding: 0.5rem 0;
    line-height: 1.25rem;
    margin: 0.25rem var(--gutter);

    // display: inline-flex;
    @include flow();
    @include ftsize(sm);
  }

  .sep {
    float: left;
    margin: 0 0.2rem;
    @include fgcolor(mute);
  }

  .crumb {
    float: left;
    @include fgcolor(tert);

    &:hover {
      @include fgcolor(primary, 5);
    }
    // float: left;

    &._caps {
      text-transform: uppercase;
      @include ftsize(xs);
    }

    :global(svg) {
      height: 1rem;
      width: 1rem;
      vertical-align: text-top;
      @include fgcolor(mute);
    }
  }
</style>
