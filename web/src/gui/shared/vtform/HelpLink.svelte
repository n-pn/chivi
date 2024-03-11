<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'
  export let key = ''

  let submenu = -1

  const helps = [
    ['Chọn từ điển', '/hd/may-dich/chon-tu-dien'],
    ['Phân loại từ', '/hd/may-dich/phan-loai-tu'],
    ['Độ ưu tiên', '/hd/may-dich/uu-tien-cum-tu'],
  ]

  $: trans = [
    // prettier-ignore
    ['G.Tran', `//translate.google.com/?sl=zh-CN&tl=en&op=translate&text=${key}`],
    ['Bing', `//www.bing.com/translator?from=zh-Hans&to=vi&text=${key}`],
    ['DeepL', ` //www.deepl.com/translator#zh/en/${key}`],
    ['Baidu', `//fanyi.baidu.com/#zh/en/${key}`],
    ['Glosbe', `//glosbe.com/zh/vi/${key}`],
    ['Vdict', `//vi.vdict.pro/cn-vi/${key}`],
    ['iCIBA', `//www.iciba.com/word?w=${key}`],
  ]

  $: links = [
    ['Thivien', `//hvdic.thivien.net/whv/${key}`],
    ['Baidu', `//www.baidu.com/s?wd=${key}`],
    ['Baike', `//baike.baidu.com/item/${key}`],
    ['Moegirl', `//mzh.moegirl.org.cn/zh-hans/${key}`],
    ['Wiki', `//zh.m.wikipedia.org/zh-hans/${key}`],
    ['Google', `//www.google.com/search?q=${key}`],
  ]

  $: submenus = [helps, trans, links]

  function trigger(node: HTMLElement, value: number) {
    const click = () => (submenu = submenu == value ? -1 : value)
    node.addEventListener('click', click, true)
    return { destroy: () => node.removeEventListener('click', click) }
  }
</script>

<footer>
  <div class="main">
    {#each ['Hướng dẫn', 'Dịch tham khảo', 'Tìm kiếm'] as type, index}
      <button class="link" class:_active={submenu == index} use:trigger={index}>
        <span>{type}</span>
        <SIcon name="caret-down" />
      </button>
    {/each}
  </div>

  {#if submenu >= 0}
    <div class="submenu">
      {#each submenus[submenu] as [name, href]}
        <a class="link" {href} target="_blank" rel="noreferrer">{name}</a>
      {/each}
    </div>
  {/if}
</footer>

<style lang="scss">
  footer {
    position: relative;
    @include border(--bd-soft, $loc: top);
  }

  .main {
    @include flex($center: horz, $gap: 0.25rem);
  }

  $height: 2.25rem;

  .link {
    display: inline-flex;
    align-items: center;
    cursor: pointer;
    gap: 0.2em;
    padding: 0 0.25rem;
    height: $height;

    @include bgcolor(tranparent);

    @include ftsize(sm);
    @include fgcolor(secd);

    &:hover,
    &._active {
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
    margin-top: -0.25rem;

    .link {
      line-height: 1.875rem;
      height: 1.875rem;
    }

    &:empty {
      display: none;
    }
  }
</style>
