<script>
  import { render_text, render_html } from '$lib/cvdata'

  export let nodes = []
  export let title = false
  export let frags = false

  let text = render_text(nodes)
  let html = null
  let body = text

  $: if (frags) {
    html ||= render_html(nodes)
    body = html
  } else {
    body = text
  }
</script>

{#if title}
  <h1 class="mtl">
    {@html body}
  </h1>
{:else}
  <p class="mtl">
    {@html body}
  </p>
{/if}

<style lang="scss">
  .mtl {
    --fgcolor: #{color(neutral, 8)};
    color: var(--fgcolor);

    @include tm-dark {
      --fgcolor: #{color(neutral, 3)};
    }
  }

  @mixin change-color($color: blue) {
    cursor: pointer;
    --border: #{color($color, 4)};
    --active: #{color($color, 6)};

    :global(.tm-dark) & {
      --border: #{color($color, 6)};
      --active: #{color($color, 4)};
    }
  }

  :global(x-v) {
    --border: transparent;
    --active: #{color(primary, 9)};

    color: var(--fgcolor);
    border-bottom: 1px solid transparent;

    .mtl:hover & {
      border-color: var(--border);
    }
  }

  :global(x-v:hover),
  :global(x-v.focus) {
    color: var(--active);
  }

  :global(x-v[data-d='1']) {
    @include change-color(teal);
  }

  :global(x-v[data-d='2']) {
    @include change-color(blue);
  }

  :global(x-v[data-d='3']) {
    @include change-color(green);
  }

  :global(x-v[data-d='9']) {
    @include change-color(gray);
  }
</style>
