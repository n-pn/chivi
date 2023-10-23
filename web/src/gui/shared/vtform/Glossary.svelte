<script lang="ts" context="module">
  type Entry = [number, Record<string, string>]
  let fetch_cache: Record<string, Entry[]> = {}
</script>

<!-- @hmr:keep-all -->
<script lang="ts">
  import { api_call } from '$lib/api_call'

  import Dialog from '$gui/molds/Dialog.svelte'
  import FormHead from './FormHead.svelte'

  import type { Rdline, Rdword } from '$lib/reader'

  export let actived = false
  export let rline: Rdline
  export let rword: Rdword

  let entries = []
  let current: Entry[] = []

  $: if (actived && rline.ztext) fetch_terms(rline.ztext, rword.from)

  async function fetch_terms(input: string, zfrom: number) {
    entries = fetch_cache[input] ||= []

    const range = []
    if (!entries[zfrom]) range.push(zfrom)

    let z_max = input.length
    if (z_max > 10) z_max = 10

    for (let index = 1; index < z_max; index++) {
      const lower = zfrom - index
      if (lower >= 0 && !entries[lower]) range.push(lower)

      const upper = zfrom + index
      if (upper < z_max && !entries[upper]) range.push(upper)

      if (range.length > 10) break
    }

    if (range.length != 0) {
      try {
        const url = `/_sp/lookup`
        const res = await api_call(url, { input, range }, 'PUT')
        for (let index in res) entries[index] = res[index]
      } catch (ex) {
        console.log(ex)
      }
    }

    current = entries[zfrom] || []
  }
</script>

<Dialog on_close={() => (actived = false)} class="vtform-lookup">
  <FormHead {rline} bind:rword bind:actived />

  <section class="choice" />

  <section class="terms">
    {#each current as [size, terms]}
      <div class="entry">
        <h3 class="word" lang="zh">
          <code>{rline.get_ztext(rword.from, rword.from + size)} </code>
          <span class="u-fg-tert"
            >{rline.get_hviet(rword.from, rword.from + size)}</span>
        </h3>

        {#each Object.entries(terms) as [dict, defn]}
          {#if defn}
            {@const defns = defn.split('\n')}

            <div class="item">
              <h4 class="name">{dict}</h4>
              {#each defns as defn}
                <p class="term">{defn}</p>
              {/each}
            </div>
          {/if}
        {/each}
      </div>
    {:else}
      <div class="d-empty-sm">
        <h5>Chưa có giải nghĩa cho cụ từ hiện tại.</h5>
        <p>
          Gợi ý: <em
            >Bấm vào chữ tiếng Trung hoặc Hán Việt phía trên để xem giải nghĩa
            cho từ ở vị trí đó.</em>
        </p>
      </div>
    {/each}
  </section>
</Dialog>

<style lang="scss">
  .terms {
    height: 40vh;
    padding: 0.75rem;
    @include scroll();
  }

  h4 {
    font-weight: 500;
    text-transform: uppercase;
    @include fgcolor(tert);
    @include ftsize(sm);
  }

  .entry {
    @include fgcolor(secd);
    // padding: 0.5rem 0;
    // padding-top: 0;
    &:not(:first-child) {
      margin-top: 0.75rem;
      padding-top: 0.5rem;
      @include border(--bd-soft, $loc: top);
    }
  }

  .item {
    margin-top: 0.25rem;

    & + & {
      margin-top: 0.5rem;
    }

    p + p {
      margin-top: 0.25rem;
    }
  }

  .term {
    @include flex($gap: 0.25rem);
    flex-wrap: wrap;
    line-height: 1.5rem;
  }
</style>
