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

<div class="upsert-links">
  {#each links as [name, href]}
    <a class="upsert-link" {href} target="_blank" rel="noopener noreferer"
      >{name}</a>
  {/each}
</div>

<style lang="scss">
  .upsert-links {
    @include flex($center: content);
  }

  .upsert-link {
    cursor: pointer;
    padding: 0 0.75rem;
    line-height: 2.25rem;

    @include font-size(2);
    @include fgcolor(neutral, 7);

    &:hover {
      @include fgcolor(primary, 5);
    }
  }
</style>
