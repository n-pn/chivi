<script lang="ts" context="module">
  type Entry = [number, Record<string, string>]
  let entries_cache: Record<string, Entry[]> = {}
</script>

<script lang="ts">
  import { data } from '$lib/stores/lookup_stores'
  import { copy_to_clipboard } from '$utils/btn_utils'
  import { api_call } from '$lib/api_call'

  import { gen_ztext_html, gen_hviet_html } from '$lib/mt_data_2'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import Viewbox from './Viewbox.svelte'

  export let viewer: HTMLElement
  export let l_idx = 0
  export let zfrom = 0
  export let zupto = 0

  $: ztext = $data.ztext[l_idx]
  $: hviet = $data.hviet[l_idx]

  let entries = []
  let current: Entry[] = []

  $: if (l_idx >= 0) fetch_terms(ztext, zfrom)

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
    current = entries[zfrom] || []

    if (current.length == 0) zupto = zfrom
    else zupto = zfrom + +current[0][0]

    if (!viewer) return

    focused.forEach((x) => x.classList.remove('focus'))
    focused.length = 0

    for (let i = zfrom; i < zupto; i++) {
      const nodes = viewer.querySelectorAll(`[data-b="${i}"]`)

      nodes.forEach((x: HTMLElement) => {
        focused.push(x)
        x.classList.add('focus')
        x.scrollIntoView({ block: 'end', behavior: 'smooth' })
      })
    }
  }
</script>

<Viewbox title="Tiếng Trung" class="_zh _lg" --lc="2">
  <svelte:fragment slot="tools">
    <button
      type="button"
      class="-btn"
      disabled={!ztext}
      data-tip="Sao chép text gốc vào clipboard"
      data-tip-loc="bottom"
      data-tip-pos="right"
      on:click={() => copy_to_clipboard(ztext)}>
      <SIcon name="copy" />
    </button>
  </svelte:fragment>

  {#if ztext}
    {@html gen_ztext_html(ztext)}
  {:else}
    <p class="empty">Chưa có tiếng trung!</p>
  {/if}
</Viewbox>

<Viewbox title="Hán Việt" class="_hv" --lc="3">
  {#if hviet}
    {@html gen_hviet_html(hviet)}
  {:else}
    <p class="empty">Chưa có Hán Việt!</p>
  {/if}
</Viewbox>

<section class="terms">
  {#each current as [size, terms]}
    <div class="entry">
      <h3 class="word" lang="zh">
        <span class="entry-key">{ztext.substring(zfrom, zfrom + size)}</span>
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

  .btn-edit {
    margin-left: auto;
    background: transparent;
  }

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
</style>
