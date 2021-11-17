<script>
  import { session } from '$app/stores'
  import SIcon from '$atoms/SIcon.svelte'
  import Appbar from '$sects/Appbar.svelte'
  import Vessel from '$sects/Vessel.svelte'

  function change_theme() {
    $session.wtheme = $session.wtheme == 'dark' ? 'light' : 'dark'
  }
</script>

<Appbar>
  <svelte:fragment slot="left">
    <span class="header-item">UIKIT</span>
  </svelte:fragment>

  <svelte:fragment slot="right">
    <button class="header-item" data-kdb="t" on:click={change_theme}>
      <SIcon name={$session.wtheme == 'dark' ? 'sun' : 'moon'} />
    </button>
  </svelte:fragment>
</Appbar>

<Vessel>
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
