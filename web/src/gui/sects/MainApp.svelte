<script>
  import Topbar from '$gui/sects/layout/Topbar.svelte'
  export let config = false
</script>

<Topbar {config}>
  <slot slot="left" name="header-left" />
  <slot slot="right" name="header-right" />
</Topbar>

<main>
  <div class="vessel"><slot /></div>
</main>

<style>
  main {
    flex: 1;
    position: relative;
  }
</style>
