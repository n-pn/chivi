<script lang="ts">
  import { page } from '$app/stores'
  import { popups } from '$lib/stores'

  import Config from './Modals/Config.svelte'
  import Appnav from './Modals/Appnav.svelte'

  import Signin from './Modals/Signin.svelte'
  import Usercp from './Modals/Usercp.svelte'
  import Dboard from './Modals/Dboard.svelte'

  $: session = $page.data._user || { uname: 'Khách' }
  $: Control = session.uname != 'Khách' ? Usercp : Signin
</script>

<aside class="popup">
  <div class="vessel">
    {#if $popups.config}<Config />{/if}
  </div>

  <Appnav bind:actived={$popups.appnav} />
  <Dboard bind:actived={$popups.dboard} />
  <svelte:component this={Control} bind:actived={$popups.usercp} />
</aside>
