<script lang="ts">
  export let ztext = ''
  export let plain = true

  function render_tokens(ztext: string) {
    let res = ''

    for (let i = 0; i < ztext.length; i++) {
      const char = ztext.charAt(i)
      res += `<z-n data-l="${i}" data-u="${i + 1}">${char}</z-n>`
    }

    return res
  }
</script>

<zh-line>
  {#if plain}{ztext}{:else}{@html render_tokens(ztext)}{/if}
</zh-line>

<style lang="scss">
  zh-line {
    display: block;
    font-family: var(--font-sans);
    line-height: 1.5em;
    letter-spacing: 0.05em;
    margin-bottom: 0.25em;

    // text-align: justify;
    // text-justify: auto;

    @include tm-light {
      color: color(neutral, 6);
    }

    @include tm-dark {
      color: color(neutral, 4);
    }
  }

  :global(z-n) {
    cursor: pointer;

    &:hover {
      border-bottom: 1px solid color(primary, 4);
    }

    &.hover {
      @include fgcolor(primary, 5);
    }

    &.focus {
      @include bgcolor(primary, 5, 2);
    }
  }
</style>
