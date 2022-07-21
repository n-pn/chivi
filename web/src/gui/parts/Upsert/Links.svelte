<script lang="ts">
  import { SIcon } from '$gui'
  export let key = ''

  let submenu = 0

  $: helps = [
    ['Chọn từ điển', '/guide/may-dich/chon-tu-dien'],
    ['Phân loại từ', '/guide/may-dich/phan-loai-tu'],
    ['Độ ưu tiên', '/guide/may-dich/uu-tien-cum-tu'],
  ]
  // prettier-ignore
  $: links = [

    ['G.Search', `//www.google.com/search?q=${key}`],
    ['Baidu', `//www.baidu.com/s?wd=${key}`],
    ['Thivien', `//hvdic.thivien.net/whv/${key}`],
    ['Moegirl', `//zh.moegirl.org.cn/zh-hans/${key}`],
    ['Wiki', `//zh.m.wikipedia.org/zh-hans/${key}`]
  ]

  // prettier-ignore
  $: trans = [
    ['G.Trans', `//translate.google.com/?sl=zh-CN&tl=en&op=translate&text=${key}`, ],
    ['Bing', `//www.bing.com/translator?from=zh-Hans&to=vi&text=${key}`],
    ['DeepL', ` //www.deepl.com/translator#zh/en/${key}`],
    ['Fanyi', `//fanyi.baidu.com/#zh/en/${key}`],
    ['iCIBA', `//www.iciba.com/word?w=${key}`],
  ]

  $: gsearch = links[0][1]

  function trigger(node: HTMLElement, value: number) {
    const click = () => (submenu = submenu == value ? 0 : value)
    node.addEventListener('click', click, true)
    return { destroy: () => node.removeEventListener('click', click) }
  }
</script>

<footer class="foot">
  <div class="main">
    <button class="link" use:trigger={1}>
      <span>Hướng dẫn</span>
      <SIcon name="caret-down" />
    </button>

    <button class="link" use:trigger={3}>
      <span>Dịch ngoài</span>
      <SIcon name="caret-down" />
    </button>

    <button class="link" use:trigger={2}>
      <span>Tra cứu</span>
      <SIcon name="caret-down" />
    </button>

    <a class="link" href={gsearch} target="_blank" rel="noopener noreferer"
      >Google</a>
  </div>

  <div class="submenu">
    {#if submenu == 1}
      {#each helps as [name, href]}
        <a class="link" {href} target="_blank" rel="noopener noreferer"
          >{name}</a>
      {/each}
    {:else if submenu == 2}
      {#each links as [name, href]}
        <a class="link" {href} target="_blank" rel="noopener noreferer"
          >{name}</a>
      {/each}
    {:else if submenu == 3}
      {#each trans as [name, href]}
        <a class="link" {href} target="_blank" rel="noopener noreferer"
          >{name}</a>
      {/each}
    {/if}
  </div>
</footer>

<style lang="scss">
  .foot {
    position: relative;
    @include border(--bd-main, $loc: top);
  }

  .main {
    @include flex($center: horz, $gap: 0.25rem);
  }

  $height: 2.25rem;

  .link {
    cursor: pointer;
    padding: 0 0.25rem;
    line-height: $height;
    height: $height;

    @include bgcolor(tranparent);

    @include ftsize(sm);
    @include fgcolor(secd);

    &:hover {
      @include fgcolor(primary, 5);
    }
  }

  .submenu {
    @include flex($center: horz, $gap: 0.375rem);
    @include bdradi($loc: bottom);
    @include border(--bd-soft, $loc: top);
    @include bgcolor(tert);

    position: absolute;
    left: 0;
    right: 0;
    top: 100%;
    // margin-top: -2px;

    .link {
      line-height: 2rem;
      height: 2rem;
    }

    &:empty {
      display: none;
    }
  }
</style>
