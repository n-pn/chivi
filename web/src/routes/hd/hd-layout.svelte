<script>
  export let title = 'Hướng dẫn'
  export let mdesc = 'Hướng dẫn sử dụng'
  export let image = '/imgs/avatar.png'
  export let mtime = ''
</script>

<svelte:head>
  <title>{title} - Chivi</title>
  <meta name="description" content={mdesc} />
  <meta property="og:title" content={title} />
  <meta property="og:description" content={mdesc} />
  <meta property="og:image" content="https://chivi.app{image}" />
</svelte:head>

<article class="article md-post island">
  <h1>{title}</h1>
  {#if mtime}<p><em>Cập nhật lần cuối: {mtime}</em></p>{/if}
  <slot />
</article>
