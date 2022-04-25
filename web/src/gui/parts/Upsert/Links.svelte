<script lang="ts">
  export let key = ''

  // prettier-ignore
  $: links = [
    ['G.Trans', `//translate.google.com/?sl=zh-CN&tl=en&op=translate&text=${key}`, ],
    ['Fanyi', `//fanyi.baidu.com/#zh/en/${key}`],
    ['Bing', `//www.bing.com/translator?from=zh-Hans&to=vi&text=${key}`],
    ['iCIBA', `//www.iciba.com/word?w=${key}`],
    ['Baidu', `//www.baidu.com/s?wd=${key}`],
    ['G.Search', `//www.google.com/search?q=${key}`],
  ]
</script>

<footer class="foot">
  {#each links as [name, href]}
    <a class="link" {href} target="_blank" rel="noopener noreferer">{name}</a>
  {/each}
</footer>

<style lang="scss">
  .foot {
    @include flex($center: horz, $gap: 0.25rem);
    @include border(--bd-main, $loc: top);
  }

  $height: 2.25rem;

  .link {
    cursor: pointer;
    padding: 0 0.5rem;
    line-height: $height;

    @include ftsize(sm);
    @include fgcolor(secd);

    &:hover {
      @include fgcolor(primary, 5);
    }
  }
</style>
