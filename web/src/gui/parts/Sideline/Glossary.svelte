<script lang="ts" context="module">
  type Entry = [number, Record<string, string>]
  let entries_cache: Record<string, Entry[]> = {}

  import type { Rdword, Rdline } from '$lib/reader'
</script>

<script lang="ts">
  import { api_call } from '$lib/api_call'

  import Viewbox from '../../molds/Wpanel.svelte'

  export let viewer: HTMLElement
  export let rline: Rdline
  export let rword: Rdword
  let entries = []
  let current: Entry[] = []

  $: if (rline.ztext) fetch_terms(rline.ztext, rword.from || 0)

  async function fetch_terms(input: string, zfrom: number) {
    entries = entries_cache[input] ||= []

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

    setTimeout(update_focus, 20)
  }

  const focused = []

  function update_focus() {
    current = entries[rword.from] || []

    let upto = rword.from
    if (current.length > 0) upto += +current[0][0]

    if (!viewer) return

    focused.forEach((x) => x.classList.remove('focus'))
    focused.length = 0

    for (let i = rword.from; i < upto; i++) {
      const nodes = viewer.querySelectorAll(`[data-b="${i}"]`)

      nodes.forEach((x: HTMLElement) => {
        focused.push(x)
        x.classList.add('focus')
        x.scrollIntoView({ block: 'end', behavior: 'smooth' })
      })
    }
  }
</script>

<Viewbox title="Tiếng Trung" class="_zh _lg" lines={2} wdata={rline.ztext}>
  {#if rline.ztext}{@html rline.ztext_html}{/if}
  <p slot="empty">Chưa có tiếng trung!</p>
</Viewbox>

<Viewbox title="Hán Việt" class="_hv" lines={3} wdata={rline.hviet_text}>
  {#if rline.hviet}{@html rline.hviet_html}{/if}
  <p slot="empty">Chưa có Hán Việt!</p>
</Viewbox>

<section class="terms">
  {#each current as [size, terms]}
    <div class="entry">
      <h3 class="word" lang="zh">
        <span class="ztext"
          >{rline.get_ztext(rword.from, rword.from + size)}</span>
        <span class="hviet" />
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
    <div class="empty">
      <h5>Chưa có giải nghĩa cho cụ từ hiện tại.</h5>
      <p>
        Gợi ý: <em
          >Bấm vào chữ tiếng Trung hoặc Hán Việt phía trên để xem giải nghĩa cho
          từ ở vị trí đó.</em>
      </p>
    </div>
  {/each}
</section>

<style lang="scss">
  .word {
    font-weight: 600;
    line-height: 2rem;
    @include ftsize(md);
  }

  h3 {
    display: flex;
  }

  // .btn-edit {
  //   margin-left: auto;
  //   background: transparent;
  // }

  h4 {
    font-weight: 500;
    text-transform: uppercase;
    @include fgcolor(tert);
    @include ftsize(sm);
  }

  .entry {
    @include fgcolor(secd);
    padding: 0.5rem 0;
    // padding-top: 0;
    @include border($loc: bottom);
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

  .empty {
    padding: 0.75rem 0;
    @include fgcolor(tert);
    // text-align: center;
    @include ftsize(sm);
    // font-style: italic;
    line-height: 1.25rem;
  }
</style>
