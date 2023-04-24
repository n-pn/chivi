<script lang="ts">
  import { opencc, diff_html } from '$utils/text_utils'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import type { PageData } from './$types'

  export let data: PageData

  let trad: string = ''

  let simp_text: string = ''
  let simp_html: string = ''

  let timer: ReturnType<typeof setTimeout>

  let _onload: boolean = false

  $: if (trad) {
    clearTimeout(timer)
    timer = setTimeout(convert, 300)
  }

  async function convert() {
    _onload = true
    simp_text = await opencc(trad, data.config)
    simp_html = diff_html(trad, simp_text, false)
    _onload = false
  }

  const options = [
    ['t2s', 'Phồn thể sang Giản'],
    ['hk2s', 'Hồng Kông sang Giản'],
    ['tw2s', 'Đài Loan sang Giản'],
  ]

  const links = [
    ['/sp/qtran', 'bolt', 'Dịch nhanh'],
    ['/sp/opencc', 'arrows-shuffle', 'Phồn -> Giản'],
  ]
</script>

<nav class="nav-list">
  {#each links as [href, icon, text]}
    <a {href} class="nav-link" class:_active={href == '/sp/opencc'}>
      <SIcon class="show-ts" name={icon} />
      <span>{text}</span>
    </a>
  {/each}
</nav>

<article class="article island">
  <header class="head">
    {#each options as [value, label]}
      <label>
        <input type="radio" name="config" bind:group={data.config} {value} />
        <span>{label}</span></label>
    {/each}
  </header>

  <section class="main">
    <div class="trad-inp">
      <textarea
        id="trad"
        name="trad"
        class="m-input trad"
        rows="10"
        placeholder="Nhập văn bản ở đây"
        bind:value={trad} />
    </div>
    <div class="simp-out">
      <div class="simp" class:_none={_onload || !simp_text}>
        {#if _onload}
          <SIcon name="loader-2" spin={_onload} />
          <span class="mute">Đang chuyển ngữ</span>
        {:else if simp_text}
          {@html simp_html}
        {:else}
          <span class="mute">Bấm [Phồn sang giản] để chuyển ngữ</span>
        {/if}
      </div>
    </div>
  </section>

  <footer class="foot">
    <button class="m-btn _primary _fill" on:click={convert}>
      <SIcon name="bolt" />
      <span class="-text">Phồn sang giản</span>
    </button>

    <button
      class="m-btn _primary"
      on:click={() => navigator.clipboard.writeText(simp_text)}>
      <SIcon name="copy" />
      <span class="-text">Chép kết quả</span>
    </button>
  </footer>
</article>

<style lang="scss">
  .nav-link,
  .article {
    margin-top: 1rem;
  }

  .head {
    @include flex-cx;
    gap: 0.5rem;
    margin-bottom: 0.75rem;
  }

  .main {
    display: flex;
    > * {
      flex: 1;
    }
  }

  textarea.trad {
    display: block;
    width: 100%;
    border-radius: 0;
    height: 60vh;
    @include bdradi($loc: left);
  }

  .foot {
    display: flex;
    gap: 0.75rem;
    justify-content: space-around;
    margin-top: 0.75rem;
  }

  .simp {
    @include border();
    border-left: none;
    @include bdradi($loc: right);

    padding: 0.375rem 0.5rem;
    height: 100%;

    :global(ins) {
      @include fgcolor(success, 5);
      font-weight: 500;
      text-decoration: none;
    }
  }

  .mute {
    @include fgcolor(tert);
    font-style: italic;
  }
</style>
