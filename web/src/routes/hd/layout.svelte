<script>
  export let title = 'Hướng dẫn'
  export let desc = 'Hướng dẫn sử dụng'
  export let image = '/imgs/avatar.png'
</script>

<svelte:head>
  <title>{title} - Chivi</title>
  <meta name="description" content={desc} />
  <meta property="og:title" content={title} />
  <meta property="og:description" content={desc} />
  <meta property="og:image" content="https://chivi.app{image}" />
</svelte:head>

<article class="article md-post">
  <h1>{title}</h1>
  <slot />
</article>
