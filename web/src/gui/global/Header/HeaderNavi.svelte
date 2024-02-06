<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'

  export let href: string = '.'
  export let text: string = ''

  export let icon: string | null = null
  export let iset = 'tabler'

  export let show = 'ps'
  export let kind = 'x'
</script>

<a {href} class="appbar-item _{kind}">
  {#if icon}<SIcon name={icon} {iset} />{/if}
  <span class="appbar-text u-show-{show}">{text}</span>
</a>
