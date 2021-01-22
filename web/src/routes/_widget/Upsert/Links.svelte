<script>
  export let key = ''
  $: links = [
    [
      'G.Trans',
      `https://translate.google.com/?sl=zh-CN&tl=en&text=${key}&op=translate`,
    ],
    ['Fanyi', `https://fanyi.baidu.com/#zh/en/${key}`],
    ['iCIBA', `https://www.iciba.com/word?w=${key}`],
    ['Baidu', `http://www.baidu.com/s?wd=${key}`],
    ['G.Search', `https://www.google.com/search?q=${key}`],
  ]
</script>

<div>
  {#each links as [name, href]}
    <a {href} target="_blank" rel="noopener noreferer">{name}</a>
  {/each}
</div>

<style lang="scss">
  div {
    @include flex($center: content);
  }

  a {
    cursor: pointer;
    padding: 0.5rem;
    line-height: 1rem;

    @include font-size(2);
    @include fgcolor(neutral, 7);

    &:hover {
      @include bgcolor(neutral, 3);
    }
  }
</style>
