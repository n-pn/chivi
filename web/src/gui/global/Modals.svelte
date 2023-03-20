<script lang="ts">
  import { popups } from '$lib/stores'

  import Config from './Modals/Config.svelte'
  import Appnav from './Modals/Appnav.svelte'
  import Usercp from './Modals/Usercp.svelte'
  import Dboard from './Modals/Dboard.svelte'
</script>

<aside class="popups">
  {#if $popups.config}<Config bind:actived={$popups.config} />{/if}
  {#if $popups.appnav}<Appnav bind:actived={$popups.appnav} />{/if}
  {#if $popups.dboard}<Dboard bind:actived={$popups.dboard} />{/if}
  {#if $popups.usercp}<Usercp bind:actived={$popups.usercp} />{/if}
</aside>
