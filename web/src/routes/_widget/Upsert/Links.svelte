<script>
  export let key = ''
  $: links = [
    [
      'G.Trans',
      `https://translate.google.com/#view=home&op=translate&sl=zh-CN&tl=en&text=${key}`,
    ],
    ['G.Search', `https://www.google.com/search?q=${key}`],
    ['Fanyi', `https://fanyi.baidu.com/#zh/en/${key}`],
    ['Baidu', `http://www.baidu.com/s?wd=${key}`],
    ['iCIBA', `https://www.iciba.com/${key}`],
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
