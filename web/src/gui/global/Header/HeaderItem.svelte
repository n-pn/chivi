<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'

  export let text: string | null = null
  export let icon: string | null = null
  export let iset = 'tabler'

  export let type: string = 'a'

  export let _dot = false
  export let opts = { show: 'ps', kind: 'x' }
</script>

<!-- svelte-ignore a11y-no-static-element-interactions -->
<svelte:element
  this={type}
  class="appbar-item _{opts.kind || 'x'}"
  class:_dot
  on:click
  {...$$restProps}>
  {#if icon}<SIcon name={icon} {iset} />{/if}
  {#if text}<span class="appbar-text u-show-{opts.show || 'ps'}">{text}</span
    >{/if}
</svelte:element>
