<script context="module">
  import { MtData, render_zh } from '$lib/mt_data'
  import { writable } from 'svelte/store'
  import { dict_lookup } from '$api/dictdb_api'

  export const enabled = writable(false)
  export const actived = writable(false)

  const input = writable('')
  const lower = writable(0)
  const upper = writable(0)

  export function activate(data, _enable) {
    if (typeof data == 'string') {
      input.set(data)
      lower.set(0)
      upper.set(data.length)
    } else {
      input.set(data[0])
      lower.set(data[1])
      upper.set(data[2])
    }

    actived.set(true)
    if (_enable) enabled.set(true)
  }
</script>

<script>
  import SIcon from '$atoms/SIcon.svelte'
  import Slider from '$molds/Slider.svelte'

  export let dname = 'various'
  // export let label = 'Tổng hợp'

  let entries = []
  let current = []

  let lookup = null

  $: if ($input) update_lookup($input)
  $: zh_text = render_zh($input)
  let hv_text = ''
  $: if ($lower >= 0 && $upper > 0) update_focus($lower)

  let tokens = []
  function highlight_focused(lower, upper) {
    if (!lookup) return
    tokens.forEach((x) => x.classList.remove('_active'))
    tokens = []

    for (let idx = lower; idx < upper; idx++) {
      const nodes = lookup.querySelectorAll(`c-v[data-i="${idx}"]`)
      nodes.forEach((x) => {
        tokens.push(x)
        x.classList.add('_active')
        x.scrollIntoView({ block: 'end', behavior: 'smooth' })
      })
    }
  }

  async function update_lookup(input) {
    const [err, data] = await dict_lookup(fetch, input, dname)
    if (err) return

    entries = data.entries
    hv_text = new MtData(data.hanviet).render_hv()
    update_focus($lower)
  }

  function handle_click({ target }) {
    const name = target.nodeName
    if (name == 'C-V') $lower = +target.dataset.i
  }

  function update_focus(lower) {
    current = entries[lower] || []

    if (current.length == 0) $upper = lower
    else $upper = lower + +current[0][0]

    setTimeout(() => highlight_focused(lower, $upper), 10)
  }
</script>

<Slider _rwidth={30} _sticky={true} bind:actived={$actived}>
  <svelte:fragment slot="header-left">
    <div class="-icon">
      <SIcon name="compass" />
    </div>
    <div class="-text">Giải nghĩa</div>
  </svelte:fragment>

  <button slot="header-right" class="-btn" on:click={() => ($enabled = false)}>
    <SIcon name="circle-off" />
  </button>

  <section class="input" bind:this={lookup}>
    <div class="input-nav _zh" on:click={handle_click} lang="zh">
      {@html zh_text}
    </div>

    <div class="input-nav _hv" on:click={handle_click}>
      {@html hv_text}
    </div>
  </section>

  <section class="terms">
    {#each current as [size, terms]}
      <div class="entry">
        <h3 class="word" lang="zh">{$input.substr($lower, size)}</h3>
        {#each Object.entries(terms) as [name, items]}
          {#if items.length > 0}
            <div class="item">
              <h4 class="name">{name}</h4>
              {#if name == 'vietphrase'}
                <p class="viet">
                  {@html items.map((x) => x || '<em>(đã xoá)</em>').join('; ')}
                </p>
              {:else}
                {#each items as line}
                  <p class="term">{line}</p>
                {/each}
              {/if}
            </div>
          {/if}
        {/each}
      </div>
    {/each}
  </section>
</Slider>

<style lang="scss">
  @mixin scroll {
    overflow-y: auto;
    scrollbar-width: thin;
    &::-webkit-scrollbar {
      cursor: pointer;
      width: 8px;
    }
  }

  .input-nav {
    padding: 0.375rem 0.75rem;
    @include bgcolor(tert);
    @include scroll;

    &._zh {
      $line: 1.375rem;
      line-height: $line;
      max-height: $line * 2 + 0.75rem;
    }

    &._hv {
      $line: 1.25rem;
      margin-top: var(--gutter-sm);
      line-height: $line;
      max-height: $line * 3 + 0.75rem;
    }
  }

  .terms {
    @include scroll;
    flex: 1;
  }

  .word {
    font-weight: 600;
    line-height: 2rem;
    @include ftsize(md);
  }

  h4 {
    font-weight: 500;
    text-transform: uppercase;
    @include fgcolor(tert);
    @include ftsize(sm);
  }

  .entry {
    @include fgcolor(secd);
    padding: 0.375rem 0.75rem;
    // padding-top: 0;
    @include border($loc: bottom);
    &:last-child {
      border: none;
    }
  }

  .item {
    & + & {
      margin-top: var(--gutter-xs);
    }
  }

  .term {
    line-height: 1.5rem;
  }
</style>
