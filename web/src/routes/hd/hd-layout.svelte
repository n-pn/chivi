<script>
  export let title = 'Hướng dẫn'
  export let mtime = ''
</script>

<article class="article md-post island">
  <h1>{title}</h1>
  {#if mtime}<p><em>Cập nhật lần cuối: {mtime}</em></p>{/if}
  <slot />
</article>
