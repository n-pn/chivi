<script lang="ts">
  import { browser } from '$app/environment'
  import { opencc, diff_html } from '$utils/text_utils'

  import SIcon from '$gui/atoms/SIcon.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  let input = ''
  let otext = ''
  let ohtml = ''

  let timer: ReturnType<typeof setTimeout>

  $: if (browser && input) {
    clearTimeout(timer)
    timer = setTimeout(convert, 300)
  }

  let _onload: boolean = false
  async function convert() {
    _onload = true
    otext = await opencc(input, data._mode)
    ohtml = diff_html(input, otext, false)
    _onload = false
  }

  const options = [
    ['t2s', 'Phồn thể sang Giản'],
    ['hk2s', 'Hồng Kông sang Giản'],
    ['tw2s', 'Đài Loan sang Giản'],
  ]

  const links = [
    ['/mt/qtran', 'langauge', 'Dịch nhanh'],
    ['/mt/tools/opencc', 'arrows-shuffle', 'Phồn -> Giản'],
  ]
</script>

<nav class="nav-list">
  {#each links as [href, icon, text]}
    <a {href} class="nav-link">
      <SIcon class="show-ts" name={icon} />
      <span>{text}</span>
    </a>
  {/each}
</nav>

<article class="article island">
  <header class="head">
    {#each options as [value, label]}
      <label>
        <input type="radio" name="config" bind:group={data._mode} {value} />
        <span>{label}</span></label>
    {/each}
  </header>

  <section class="main">
    <div class="input">
      <textarea
        id="inp"
        name="inp"
        class="m-input inp"
        rows="10"
        placeholder="Nhập văn bản ở đây"
        bind:value={input} />
    </div>
    <div class="out" class:_none={_onload || !otext}>
      {#if _onload}
        <SIcon name="loader-2" spin={_onload} />
        <span class="mute">Đang chuyển ngữ</span>
      {:else if otext}
        {@html ohtml}
      {:else}
        <span class="mute">Bấm [Phồn sang giản] để chuyển ngữ</span>
      {/if}
    </div>
  </section>

  <footer class="foot">
    <button class="m-btn _primary _fill" on:click={convert}>
      <SIcon name="bolt" />
      <span class="-text">Phồn sang giản</span>
    </button>

    <button
      class="m-btn _primary"
      on:click={() => navigator.clipboard.writeText(otext)}>
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

  textarea.inp {
    display: block;
    width: 100%;
    border-radius: 0;
    height: 60vh;
    @include bdradi($loc: left);
  }

  .out {
    padding: 0.375rem 0.5rem;
    white-space: pre-wrap;

    @include border();
    border-left: none;
    @include bdradi($loc: right);

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

  .foot {
    display: flex;
    gap: 0.75rem;
    justify-content: space-around;
    margin-top: 0.75rem;
  }
</style>
