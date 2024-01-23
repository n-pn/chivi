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

  const vi_tags = {
    NOUN: 'Danh từ',
    PRON: 'Đại từ',
    ADJ: 'Tính từ',
    PREP: 'Giới từ',
    VERB: 'Động từ',
    ADV: 'Phó từ',
    CONJ: 'Liên từ',
    DET: 'Khu biệt',
  }
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
        <div class="line _head">
          <span>
            <span class="lbl">Nghĩa: </span>
            <span class="val">{defn.displayTarget}</span>
          </span>
          <span>
            <span class="lbl" data-tip="Từ loại của nghĩa">Từ loại: </span>
            <span class="val _postag" data-tip={defn.posTag}
              >{vi_tags[defn.posTag] || defn.posTag}</span>
            <span class="val _confidence" data-tip="Độ tinh cậy"
              >({defn.confidence})</span>
          </span>
        </div>

        <div class="back">
          <span class="lbl">Dịch ngược: </span>
          <span class="words">
            {#each defn.backTranslations as back}
              <a
                class="word"
                href="/tools/lookup?word={back.displayText}"
                data-tip="Tần suất: {back.frequencyCount}"
                >{back.displayText}</a>
            {/each}
          </span>
        </div>
      </div>
    {:else}
      <div class="d-empty">Không có kết quả</div>
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
    grid-template-columns: repeat(auto-fill, minmax(18rem, 1fr));
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
    // justify-content: space-between;
    flex-wrap: wrap;
    gap: 1rem;
    line-height: 1.5rem;

    > span {
      display: flex;
      gap: 0.5rem;
    }
  }

  .back {
    margin-top: 0.5rem;
  }

  .word {
    margin: 0 0.5rem;
    font-weight: 500;

    @include fgcolor(primary, 4);
    @include hover {
      @include fgcolor(primary, 5);
      border-bottom: 1px solid currentColor;
    }
  }

  // .empty {
  //   @include fgcolor(mute);
  //   @include flex-ca;
  //   font-style: italic;
  //   grid-column: 1/-1;
  //   height: 5rem;
  // }
</style>
