<script context="module" lang="ts">
  export interface BingBackTrans {
    displayText: string
    numExamples: number
    frequencyCount: number
  }

  export interface BingDefn {
    displayTarget: string
    posTag: string
    confidence: number
    backTranslations: BingBackTrans[]
  }

  // const sample = [
  //   {
  //     normalizedTarget: 'own',
  //     displayTarget: 'own',
  //     posTag: 'ADJ',
  //     confidence: 0.2015,
  //     prefixWord: '',
  //     backTranslations: [
  //       {
  //         normalizedText: '自己',
  //         displayText: '自己',
  //         numExamples: 15,
  //         frequencyCount: 29374,
  //       },
  //       {
  //         normalizedText: '拥有',
  //         displayText: '拥有',
  //         numExamples: 15,
  //         frequencyCount: 2574,
  //       },
  //       {
  //         normalizedText: '自身',
  //         displayText: '自身',
  //         numExamples: 15,
  //         frequencyCount: 1539,
  //       },
  //       {
  //         normalizedText: '个人',
  //         displayText: '个人',
  //         numExamples: 15,
  //         frequencyCount: 525,
  //       },
  //     ],
  //   },
  //   {
  //     normalizedTarget: 'yourself',
  //     displayTarget: 'yourself',
  //     posTag: 'PRON',
  //     confidence: 0.1891,
  //     prefixWord: '',
  //     backTranslations: [
  //       {
  //         normalizedText: '自己',
  //         displayText: '自己',
  //         numExamples: 15,
  //         frequencyCount: 21543,
  //       },
  //     ],
  //   },
  //   {
  //     normalizedTarget: 'myself',
  //     displayTarget: 'myself',
  //     posTag: 'PRON',
  //     confidence: 0.1792,
  //     prefixWord: '',
  //     backTranslations: [
  //       {
  //         normalizedText: '自己',
  //         displayText: '自己',
  //         numExamples: 15,
  //         frequencyCount: 19286,
  //       },
  //     ],
  //   },
  //   {
  //     normalizedTarget: 'himself',
  //     displayTarget: 'himself',
  //     posTag: 'PRON',
  //     confidence: 0.1641,
  //     prefixWord: '',
  //     backTranslations: [
  //       {
  //         normalizedText: '自己',
  //         displayText: '自己',
  //         numExamples: 15,
  //         frequencyCount: 15324,
  //       },
  //     ],
  //   },
  //   {
  //     normalizedTarget: 'themselves',
  //     displayTarget: 'themselves',
  //     posTag: 'PRON',
  //     confidence: 0.1385,
  //     prefixWord: '',
  //     backTranslations: [
  //       {
  //         normalizedText: '自己',
  //         displayText: '自己',
  //         numExamples: 15,
  //         frequencyCount: 10626,
  //       },
  //     ],
  //   },
  //   {
  //     normalizedTarget: 'their',
  //     displayTarget: 'their',
  //     posTag: 'PRON',
  //     confidence: 0.1277,
  //     prefixWord: '',
  //     backTranslations: [
  //       {
  //         normalizedText: '他们',
  //         displayText: '他们',
  //         numExamples: 15,
  //         frequencyCount: 115407,
  //       },
  //       {
  //         normalizedText: '自己',
  //         displayText: '自己',
  //         numExamples: 15,
  //         frequencyCount: 33786,
  //       },
  //     ],
  //   },
  // ]
</script>

<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'

  import { browser } from '$app/environment'
  import { debounce } from '$lib/svelte'
  import type { PageData } from './$types'

  export let data: PageData

  let bing_defns: BingDefn[] = []

  const get_bing_defn = async (word: string) => {
    const url = `/_sp/defns/${word}`
    const res = await fetch(url)
    if (res.ok) bing_defns = await res.json()
    else alert(await res.text())
  }

  const debounce_get_bing_defn = debounce(get_bing_defn, 300)
  $: if (browser) debounce_get_bing_defn(data.word)
</script>

<article class="article island">
  <header>
    <input class="m-input _large" type="text" bind:value={data.word} />
    <button
      type="button"
      class="m-btn _primary _large"
      on:click={() => get_bing_defn(data.word)}>
      <SIcon name="search" />
    </button>
  </header>

  <section>
    {#each bing_defns as defn}
      <div class="defn">
        <div class="line ">
          <span>
            <span class="lbl">Nghĩa: </span>
            <span class="val">{defn.displayTarget}</span>
          </span>

          <span>
            <span class="lbl">Từ loại: </span>
            <span class="val _postag">{defn.posTag}</span>
          </span>
          <span>
            <span class="lbl">Tần suất: </span>
            <span class="val _confidence">{defn.confidence}</span>
          </span>
        </div>

        <div class="back">
          <span class="lbl">Dịch ngược: </span>
          <span class="words">
            {#each defn.backTranslations as back}
              <a
                class="word"
                href="/tools/lookup?word={back.displayText}"
                data-tip={back.frequencyCount}>{back.displayText}</a>
            {/each}
          </span>
        </div>
      </div>
    {/each}
  </section>
</article>

<style lang="scss">
  article {
    margin-top: var(--gutter);
  }

  header {
    @include flex-ca;
    gap: 0.5rem;
  }

  section {
    padding: 1rem;
    display: grid;
    grid-template-columns: repeat(2, minmax(5rem, 1fr));
    min-height: 5rem;
    gap: 0.5rem;
  }

  .defn {
    @include shadow;
    @include bdradi;
    padding: 0.5rem 1rem;
  }

  .lbl {
    @include fgcolor(tert);
  }

  .val {
    font-weight: 500;
    @include fgcolor(secd);

    &._postag {
      @include fgcolor(warning);
    }

    &._confidence {
      @include fgcolor(success);
    }
  }

  .line {
    display: flex;
    justify-content: space-between;
    > span {
      display: flex;
      gap: 0.5rem;
    }
  }

  .back {
    margin-top: 0.5rem;
  }

  .word {
    margin-left: 0.5rem;
    font-weight: 500;

    @include fgcolor(primary, 4);
    @include hover {
      @include fgcolor(primary, 5);
      border-bottom: 1px solid currentColor;
    }
  }
</style>
