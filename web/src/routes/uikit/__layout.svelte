<script>
  import { session } from '$app/stores'
  import SIcon from '$atoms/SIcon.svelte'
  import Vessel from '$sects/Vessel.svelte'

  function change_theme() {
    $session.site_theme = $session.site_theme == 'dark' ? 'light' : 'dark'
  }

  function handle_key(evt) {
    if (evt.keyCode == 84) {
      change_theme()
    }
  }
</script>

<svelte:window on:keydown={handle_key} />
<Vessel>
  <svelte:fragment slot="header-left">
    <span class="header-item">UIKIT</span>
  </svelte:fragment>

  <svelte:fragment slot="header-right">
    <button class="header-item" on:click={change_theme}>
      <SIcon name={$session.site_theme == 'dark' ? 'sun' : 'moon'} />
    </button>
  </svelte:fragment>

  <nav>
    <a href="/uikit/colors">Colors</a>
    <a href="/uikit/buttons">Buttons</a>
    <a href="/uikit/inputs">Inputs</a>
  </nav>

  <article class="m-text m-article">
    <slot />
  </article>
</Vessel>

<style lang="scss">
  nav {
    @include flex($center: both, $gap: 0.25rem);
  }

  a {
    padding: 0.5rem;
    color: var(--color-link);
  }
</style>
