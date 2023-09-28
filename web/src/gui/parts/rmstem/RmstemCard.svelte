<script lang="ts">
  export let rstem: CV.Upstem

  $: href = `/up/${rstem.sname}:${rstem.id}`

  $: intro = rstem.vintro.split('\n').slice(0, 3).join()
  $: uname = rstem.sname.substring(1)
</script>

<article class="rstem">
  <div class="xtags m-chips">
    <a class="m-chip _xs _primary" href="/up?by={uname}">{rstem.sname}</a>
    {#each rstem.labels as label}
      <a class="m-chip _xs" href="/up?lb={label}">{label}</a>
    {/each}
  </div>
  <a class="title" {href}>{rstem.vname}</a>
  <p class="intro">{intro}...</p>
</article>

<style lang="scss">
  .rstem {
    padding: 0.5rem 1rem;
    // max-width: 30rem;

    @include bgcolor(secd);
    @include bdradi;
    @include border;

    & + :global(.rstem) {
      margin-top: 1rem;
    }
  }

  .xtags {
    display: flex;
    gap: 0.2rem;
  }

  .title {
    display: block;
    padding: 0.5rem 0;

    @include ftsize(lg);
    @include fgcolor(secd);
    &:hover {
      @include fgcolor(primary);
    }
  }

  .intro {
    @include fgcolor(tert);
    font-style: italic;
    @include ftsize(sm);
    line-height: 1.25rem;
    @include clamp($lines: 2);
  }
</style>
