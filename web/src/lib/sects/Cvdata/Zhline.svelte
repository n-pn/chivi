<script>
  export let ztext = ''
  export let plain = true
</script>

<zh-line>
  {#if plain}
    {ztext}
  {:else}
    {#each Array.from(ztext) as char, idx}
      <z-n data-l={idx} data-u={idx + 1}>{char}</z-n>
    {/each}
  {/if}
</zh-line>

<style lang="scss">
  zh-line {
    display: block;
    font-family: san-serif;
    // font-size: 0.95em;
    line-height: 1.4em;
    letter-spacing: 0.04em;
    margin-bottom: 0.25em;
    @include tm-light {
      color: color(neutral, 6);
    }

    @include tm-dark {
      color: color(neutral, 4);
    }
  }

  z-n {
    cursor: pointer;

    &:global(.focus) {
      @include fgcolor(primary, 5);
    }
  }
</style>
