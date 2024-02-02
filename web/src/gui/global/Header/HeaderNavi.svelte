<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'

  export let hd_text: string | null = null
  export let hd_icon: string | null = null

  export let hd_show = 'ps'
  export let hd_kind = 'x'

  export let href: string = '.'
  export let text: string = ''
  export let iset = 'tabler'
</script>

<a {href} class="appbar-item _{hd_kind}">
  {#if hd_icon}<SIcon name={hd_icon} {iset} />{/if}
  <span class="appbar-text u-show-{hd_show}">{hd_text || text}</span>
</a>
