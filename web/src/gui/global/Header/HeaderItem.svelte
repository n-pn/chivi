<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'

  export let text: string | null = null
  export let icon: string | null = null

  export let show = 'ps'
  export let kind = 'x'

  export let iset = 'tabler'
  export let type = 'a'

  export let _dot = false
</script>

<!-- svelte-ignore a11y-no-static-element-interactions -->
<svelte:element
  this={type}
  class="appbar-item _{kind}"
  class:_dot
  on:click
  {...$$restProps}>
  {#if icon}<SIcon name={icon} {iset} />{/if}
  {#if text}<span class="appbar-text u-show-{show}">{text}</span>{/if}
</svelte:element>
