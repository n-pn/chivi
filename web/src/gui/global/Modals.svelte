<script lang="ts">
  import { page } from '$app/stores'
  import { popups } from '$lib/stores'

  import Config from './Modals/Config.svelte'
  import Appnav from './Modals/Appnav.svelte'

  import Usercp from './Modals/Usercp.svelte'
  import Dboard from './Modals/Dboard.svelte'

  $: session = $page.data._user || { uname: 'Khách' }
</script>

<aside class="popups">
  <div class="app-vessel">
    {#if $popups.config}<Config />{/if}
  </div>

  <Appnav bind:actived={$popups.appnav} />
  <Dboard bind:actived={$popups.dboard} />
  {#if session.uname != 'Khách'}<Usercp bind:actived={$popups.usercp} />{/if}
</aside>

<style lang="scss">
  .app-vessel {
    > :global(*) {
      margin-right: var(--gutter);
    }
  }
</style>
